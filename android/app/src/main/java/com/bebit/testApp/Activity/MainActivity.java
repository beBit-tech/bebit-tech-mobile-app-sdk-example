package com.bebit.testApp.Activity;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.inputmethod.EditorInfo;
import android.widget.EditText;
import android.widget.LinearLayout;

import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.bebittech.omnisegment.OSGEvent;
import com.bebittech.omnisegment.OSGProduct;
import com.bebittech.omnisegment.OmniSegment;
import com.bebit.testApp.Adapter.PupolarAdapter;
import com.bebit.testApp.Domain.PopularDomain;
import com.bebit.testApp.R;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class MainActivity extends AppCompatActivity {
  private PupolarAdapter adapterPupolar;
  private RecyclerView recyclerViewPupolar;

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_main);

    initRecyclerView();
    bottomNavigation();
    setupSearchListener();
  }

  private void setupSearchListener() {
    EditText searchEditText = findViewById(R.id.editTextText);
    searchEditText.setOnEditorActionListener((v, actionId, event) -> {
      if (actionId == EditorInfo.IME_ACTION_SEARCH || actionId == 0) {
        submitSearchEvent(v.getText().toString());
        return true;
      }
      return false;
    });
  }

  private void submitSearchEvent(String searchQuery) {
    Map<String, Object> searchLabel = new HashMap<>();
    searchLabel.put("search_string", searchQuery);
    // OmniSegment SDK
    // Wiki: https://github.com/beBit-tech/bebit-tech-android-app-sdk/wiki/Send-Action-(Event)-Examples#submit-a-search
    // Purpose: Track search queries to understand user search behavior and intent
    OSGEvent searchEvent = OSGEvent.search(searchLabel);
    searchEvent.location = "app://HomePage";
    searchEvent.locationTitle = "Home page";
    OmniSegment.trackEvent(searchEvent);
  }

  @Override
  protected void onResume() {
    super.onResume();
    // OmniSegment SDK
    // Wiki: https://github.com/beBit-tech/bebit-tech-android-app-sdk/wiki/Usage#set-current-page
    // Purpose: Track current page/screen for user journey analytics
    OmniSegment.setCurrentPage("Home");
  }

  private void bottomNavigation() {
    LinearLayout homeBtn = findViewById(R.id.homeBtn);
    LinearLayout cartBtn = findViewById(R.id.cartBtn);
    LinearLayout profileBtn = findViewById(R.id.profileBtn);
    profileBtn.setOnClickListener(v -> startActivity(new Intent(MainActivity.this, ProfileActivity.class)));

    homeBtn.setOnClickListener(v -> startActivity(new Intent(MainActivity.this, MainActivity.class)));
    cartBtn.setOnClickListener(v -> startActivity(new Intent(MainActivity.this, CartActivity.class)));

  }

  private void initRecyclerView() {
    ArrayList<PopularDomain> items = new ArrayList<>();
    items.add(new PopularDomain("モクロー", "羽毛はほとんどが薄茶またはベージュ色で\n" +
        " 脚の付け根.\n" +
        " 顔の周りは白\n" +
        " 通常は見えないが翼の内側は付け根あたりが緑色.\n" +
        " 目は黒く大きく\n" +
        " 夜目が効く\n" +
        " くちばしは短く、\n" +
        "上が白で下がオレンジ色。\n" +
        " 胸の部分に双葉のよ うな緑色の模様がある \n" +
        "翼は大きくないものの\n" +
        " 羽根が刃物のように鋭い葉っぱと一体化しており", "item1", 15, 4, 500));
    items.add(new PopularDomain("メタモン", "変身能力を持つ数少ないポケモン\n" +
        " 紫色（一部ではピンク色）.\n" +
        " をしたスライム状の体組織を持ち\n" +
        " 他のポケモンをはじめ.\n" +
        " 非生物や人間にまで変身することがある\n" +
        " これによりどんなポケモンや人間とも仲間になれる\n" +
        " 笑うと力が抜けて変身が解ける.\n" +
        "メタモン同士が出会うと\n" +
        " 相手とそっくりな形になろうと活発に動く \n" +
        "メタモン同士の仲は悪い。\n" +
        " 寝る時は外敵から身を守るため石に変身する。", "item2", 10, 4.5, 450));
    items.add(new PopularDomain("ヤドン", "分厚いクリーム色の唇とカールした耳が特徴のポケモン\n" +
        " 4足歩行で全身は薄いピンク色、\n" +
        " 四肢と胴と同じくらい長い尻尾の先が白い。\n" +
        " 普段はポカンとした表情を常に浮かべて、\n" +
        " ボーっとしている。\n" +
        " コロコロ表情を変えないため、\n" +
        " 傍から見ると何を考えているのかわからない。\n" +
        "性格は温厚、\n" +
        " 泳ぐのはあまり得意ではなく", "item3", 15, 4.3, 800));
    items.add(new PopularDomain(" イーブイ", "4足歩行型の小動物ポケモン。\n" +
        " 黒い瞳の大きな目にウサギのような長い耳とキツネのような尻尾を持つ\n" +
        " 体色は茶色で、首の周りを覆う襟巻\n" +
        " き状の白い毛が特徴。\n" +
        " 周囲の環境に合わせて体のつくりを変えていく持ち主。\n" +
        " 姿を変えることにより、\n" +
        " 様々な厳しい環境への対応が可能に\n" +
        " 現時点で8種のポケモンに進化する。", "item4", 18, 4.0, 1500));

    recyclerViewPupolar = findViewById(R.id.view1);
    recyclerViewPupolar.setLayoutManager(new LinearLayoutManager(this, LinearLayoutManager.HORIZONTAL, false));

    adapterPupolar = new PupolarAdapter(items);
    recyclerViewPupolar.setAdapter(adapterPupolar);

    List<OSGProduct> osgProducts = new ArrayList<>();
    for (PopularDomain item : items) {
      OSGProduct osgProduct = new OSGProduct(item.getId(), item.getTitle());
      osgProduct.price = (int) item.getPrice();

      osgProducts.add(osgProduct);
    }
    // OmniSegment SDK
    // Wiki: https://github.com/beBit-tech/bebit-tech-android-app-sdk/wiki/Send-Action-(Event)-Examples#product-impressions
    // Purpose: Track when products are displayed to users (for conversion funnel analysis)
    OSGEvent event = OSGEvent.productImpression(osgProducts);
    event.locationTitle = "ポケットモンスター";
    event.location = "app://productList";
    OmniSegment.trackEvent(event);

    adapterPupolar.setOnItemClickListener(item -> {

      OSGProduct clickedProduct = new OSGProduct(item.getTitle(), item.getTitle());
      clickedProduct.price = (int) item.getPrice();
      // OmniSegment SDK
      // Wiki: https://github.com/beBit-tech/bebit-tech-android-app-sdk/wiki/Send-Action-(Event)-Examples#product-clicks
      // Purpose: Track product click events to measure user engagement with products
      OSGEvent clickEvent = OSGEvent.productClicked(Collections.singletonList(clickedProduct));
      clickEvent.locationTitle = "ポケットモンスター";
      clickEvent.location = "app://productList";
      OmniSegment.trackEvent(clickEvent);
    });
  }

}
