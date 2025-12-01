package com.bebit.testApp.Activity;

import android.os.Bundle;
import android.util.Log;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

import com.bebittech.omnisegment.OSGEvent;
import com.bebittech.omnisegment.OSGProduct;
import com.bebittech.omnisegment.OmniSegment;
import com.bumptech.glide.Glide;
import com.bebit.testApp.Domain.PopularDomain;
import com.bebit.testApp.Helper.ManagmentCart;
import com.bebit.testApp.R;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

public class DetailActivity extends AppCompatActivity {
    private Button addToCartBtn;
    private TextView titleTxt, feeTxt, descriptionTxt, reviewTxt, scoreTxt;
    private ImageView picItem, backBtn;
    private PopularDomain object;
    private int numberOrder = 1;
    private ManagmentCart managmentCart;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_detail);

        ImageView starIcon = findViewById(R.id.star);
        starIcon.setOnClickListener(v -> {
            toggleStarEffect();
            submitCustomEvent();
            submitWishEvent(object.getId(), object.getTitle(), (int) object.getPrice());
        });

        managmentCart = new ManagmentCart(this);

        initView();
        getBundle();
    }

    private void toggleStarEffect() {
        ImageView starIcon = findViewById(R.id.star);
        starIcon.setImageResource(R.drawable.star_filled);
    }

    private void submitCustomEvent() {
        // OmniSegment SDK custom event
        // Wiki: https://github.com/beBit-tech/bebit-tech-android-app-sdk/wiki/Send-Action-(Event)-Examples#custom-event
        // Purpose: Track custom events specific to your business needs (e.g., newsletter subscription)
        OSGEvent customEvent = OSGEvent.custom("SubscriptionEmail", "RENEE@bebit-tech.com");
        customEvent.location = "app://detailPage";
        customEvent.locationTitle = "Detail Page";
        OmniSegment.trackEvent(customEvent);
    }

    private void submitWishEvent(String productId, String productName, int productPrice) {
        OSGProduct product = new OSGProduct(productId, productName);
        product.price = productPrice;
        // OmniSegment SDK
        // Wiki: https://github.com/beBit-tech/bebit-tech-android-app-sdk/wiki/Send-Action-(Event)-Examples#product-detail-impressions
        // Purpose: Track when users add products to their wishlist (for remarketing and user preference analysis)
        OSGEvent wishEvent = OSGEvent.addToWishlist(Arrays.asList(product));
        wishEvent.location = "app://detailPage";
        wishEvent.locationTitle = "Detail Page";

        OmniSegment.trackEvent(wishEvent);
        Toast.makeText(DetailActivity.this, "Added to Wishlist", Toast.LENGTH_SHORT).show();

    }



    @Override
    protected void onResume() {
        super.onResume();
        // OmniSegment SDK
        // Wiki: https://github.com/beBit-tech/bebit-tech-android-app-sdk/wiki/Usage#set-current-page
        // Purpose: Track current page/screen for user journey analytics
        OmniSegment.setCurrentPage("Detail");

        if (object != null) {

            OSGProduct product = new OSGProduct(object.getId(), object.getTitle());
            product.price = (int) object.getPrice();
            // OmniSegment SDK
            // Wiki: https://github.com/beBit-tech/bebit-tech-android-app-sdk/wiki/Send-Action-(Event)-Examples#product-impressions
            // Purpose: Track product detail page views for conversion funnel analysis
            OSGEvent event = OSGEvent.productImpression(Arrays.asList(product));
            event.location = "app://productDetail";
            event.locationTitle = "ポケモンガラルずかん";
            OmniSegment.trackEvent(event);
        }

    }

    private void getBundle() {
        object = (PopularDomain) getIntent().getSerializableExtra("object");
        int drawableResourceId = this.getResources().getIdentifier(object.getPicUrl(), "drawable", this.getPackageName());

        Glide.with(this)
                .load(drawableResourceId)
                .into(picItem);

        titleTxt.setText(object.getTitle());
        feeTxt.setText("$" + object.getPrice());
        descriptionTxt.setText(object.getDescription());
        reviewTxt.setText(object.getReview() + "");
        scoreTxt.setText(object.getScore() + "");

        addToCartBtn.setOnClickListener(v -> {
            object.setNumberInCart(numberOrder);
            managmentCart.insertFood(object);
            OSGProduct cartProduct = new OSGProduct(object.getId(), object.getTitle());
            cartProduct.price = (int) object.getPrice();

            // Wiki: https://github.com/beBit-tech/bebit-tech-android-app-sdk/wiki/Send-Action-(Event)-Examples#add-to-cart
            // Purpose: Track when users add products to cart (key conversion funnel metric)
            OSGEvent cartEvent = OSGEvent.addToCart(Arrays.asList(cartProduct));
            cartEvent.location = "app://productDetail";
            cartEvent.locationTitle = "モクロー";
            OmniSegment.trackEvent(cartEvent);

        });
        backBtn.setOnClickListener(v -> finish());
    }

    private void initView() {
        addToCartBtn = findViewById(R.id.addToCartBtn);
        feeTxt = findViewById(R.id.priceTxt);
        titleTxt = findViewById(R.id.titleTxt);
        descriptionTxt = findViewById(R.id.descriptionTxt);
        picItem = findViewById(R.id.itemPic);
        reviewTxt = findViewById(R.id.reviewTxt);
        scoreTxt = findViewById(R.id.scoreTxt);
        backBtn = findViewById(R.id.backBtn);
    }
}
