package com.bebit.testApp.Activity;

import android.os.Bundle;
import android.view.View;
import android.widget.ImageView;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.AppCompatButton;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.bebittech.omnisegment.OSGEvent;
import com.bebittech.omnisegment.OSGProduct;
import com.bebittech.omnisegment.OmniSegment;
import com.bebit.testApp.Adapter.CartAdapter;
import com.bebit.testApp.Domain.PopularDomain;
import com.bebit.testApp.Helper.ManagmentCart;
import com.bebit.testApp.R;
import com.google.android.material.button.MaterialButton;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class CartActivity extends AppCompatActivity {
  private RecyclerView.Adapter adapter;
  private RecyclerView recyclerView;
  private ManagmentCart managmentCart;
  private TextView totalFeeTxt, taxTxt, deliveryTxt, totalTxt, emptyTxt;
  private double tax;
  private ScrollView scrollView;
  private ImageView backBtn;

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_cart);

    managmentCart = new ManagmentCart(this);

    initView();
    setVariable();
    calculateCart();
    initList();

    MaterialButton purchaseButton = findViewById(R.id.purchaseButton);
    MaterialButton refundButton = findViewById(R.id.refundButton);
    purchaseButton.setOnClickListener(new View.OnClickListener() {
      @Override
      public void onClick(View v) {
        handlePurchase();
      }
    });

    refundButton.setOnClickListener(new View.OnClickListener() {
      @Override
      public void onClick(View v) {
        handleRefund();
      }
    });

    List<OSGProduct> osgProducts = new ArrayList<>();
    // Wiki: https://github.com/beBit-tech/bebit-tech-android-app-sdk/wiki/Send-Action-(Event)-Examples#product-impressions
    // Purpose: Track cart page product impressions for conversion funnel analysis
    OSGEvent event = OSGEvent.productImpression(osgProducts);
    event.locationTitle = "cart";
    event.location = "app://cart";
    OmniSegment.trackEvent(event);
  }

  private void handlePurchase() {
    List<OSGProduct> productsInCart = getProductsInCart();

    String transactionId = UUID.randomUUID().toString();
    double percentTax = 0.02;
    double delivery = 10;
    tax = Math.round(managmentCart.getTotalFee() * percentTax * 100.0) / 100.0;

    double total = Math.round((managmentCart.getTotalFee() + tax + delivery) * 100) / 100;
    Double revenue = total;
    // OmniSegment SDK
    // Wiki: https://github.com/beBit-tech/bebit-tech-android-app-sdk/wiki/Send-Action-(Event)-Examples#purchases
    // Purpose: Track successful purchase transactions with transaction details (revenue, tax, shipping, products)
    OSGEvent purchaseEvent = OSGEvent.purchase(transactionId, revenue.intValue(), productsInCart);
    purchaseEvent.location = "app://cart";
    purchaseEvent.locationTitle = "Cart Page";
    purchaseEvent.transactionShipping = String.valueOf(delivery);
    purchaseEvent.transactionTax = String.valueOf(tax);

    OmniSegment.trackEvent(purchaseEvent);
    Toast.makeText(CartActivity.this, "Purchase successful", Toast.LENGTH_SHORT).show();

  }

  private void handleRefund() {
    List<OSGProduct> productsInCart = getProductsInCart();

    String transactionId = UUID.randomUUID().toString();
    double percentTax = 0.02;
    double delivery = 10;
    tax = Math.round(managmentCart.getTotalFee() * percentTax * 100.0) / 100.0;

    double total = Math.round((managmentCart.getTotalFee() + tax + delivery) * 100) / 100;
    Double revenue = total;

    // Wiki: https://github.com/beBit-tech/bebit-tech-android-app-sdk/wiki/Send-Action-(Event)-Examples#refund
    // Purpose: Track refund transactions to monitor return rates and revenue adjustments
    OSGEvent purchaseEvent = OSGEvent.refund(transactionId, revenue.intValue(), productsInCart);
    purchaseEvent.location = "app://cart";
    purchaseEvent.locationTitle = "Cart Page";
    purchaseEvent.transactionShipping = String.valueOf(delivery);
    purchaseEvent.transactionTax = String.valueOf(tax);

    OmniSegment.trackEvent(purchaseEvent);
    Toast.makeText(CartActivity.this, "Refund processed", Toast.LENGTH_SHORT).show();
  }

  @Override
  protected void onResume() {
    super.onResume();
    // OmniSegment SDK
    // Wiki: https://github.com/beBit-tech/bebit-tech-android-app-sdk/wiki/Usage#set-current-page
    // Purpose: Track current page/screen for user journey analytics
    OmniSegment.setCurrentPage("Cart");

    List<OSGProduct> productsInCart = getProductsInCart();
    // OmniSegment SDK
    // Wiki: https://github.com/beBit-tech/bebit-tech-android-app-sdk/wiki/Send-Action-(Event)-Examples#checkout
    // Purpose: Track checkout initiation to measure cart-to-checkout conversion
    OSGEvent checkoutEvent = OSGEvent.checkout(productsInCart);
    checkoutEvent.location = "app://cart";
    checkoutEvent.locationTitle = "Cart Page";
    OmniSegment.trackEvent(checkoutEvent);
  }

  private List<OSGProduct> getProductsInCart() {
    List<OSGProduct> products = new ArrayList<>();
    for (PopularDomain item : managmentCart.getListCart()) {
      OSGProduct product = new OSGProduct(item.getId(), item.getTitle());
      product.price = (int) item.getPrice();
      // product.quantity = item.getNumberInCart();

      products.add(product);
    }
    return products;
  }

  private void initList() {
    if (managmentCart.getListCart().isEmpty()) {
      emptyTxt.setVisibility(View.VISIBLE);
      scrollView.setVisibility(View.GONE);
    } else {
      emptyTxt.setVisibility(View.GONE);
      scrollView.setVisibility(View.VISIBLE);
    }

    LinearLayoutManager linearLayoutManager = new LinearLayoutManager(this, LinearLayoutManager.VERTICAL, false);
    recyclerView.setLayoutManager(linearLayoutManager);

    adapter = new CartAdapter(managmentCart.getListCart(), this, () -> calculateCart());
    recyclerView.setAdapter(adapter);
  }

  private void calculateCart() {
    double percentTax = 0.02;
    double delivery = 10;
    tax = Math.round(managmentCart.getTotalFee() * percentTax * 100.0) / 100.0;

    double total = Math.round((managmentCart.getTotalFee() + tax + delivery) * 100) / 100;
    double itemTotal = Math.round(managmentCart.getTotalFee() * 100) / 100;

    totalFeeTxt.setText("$" + itemTotal);
    taxTxt.setText("$" + tax);
    deliveryTxt.setText("$" + delivery);
    totalTxt.setText("$" + total);
  }

  private void setVariable() {
    backBtn.setOnClickListener(v -> finish());
  }

  private void initView() {
    totalFeeTxt = findViewById(R.id.totalFeeTxt);
    taxTxt = findViewById(R.id.taxTxt);
    deliveryTxt = findViewById(R.id.deliveryTxt);
    totalTxt = findViewById(R.id.totalTxt);
    recyclerView = findViewById(R.id.view2);
    scrollView = findViewById(R.id.scrollView2);
    backBtn = findViewById(R.id.backBtn);
    emptyTxt = findViewById(R.id.emptyTxt);
  }
}
