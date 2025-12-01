package com.bebit.testApp.Helper;

import android.content.Context;
import android.widget.Toast;

import com.bebittech.omnisegment.OSGEvent;
import com.bebittech.omnisegment.OSGProduct;
import com.bebittech.omnisegment.OmniSegment;
import com.bebit.testApp.Domain.PopularDomain;

import java.util.ArrayList;
import java.util.Arrays;

public class ManagmentCart {
    private Context context;
    private TinyDB tinyDB;

    public ManagmentCart(Context context) {
        this.context = context;
        this.tinyDB=new TinyDB(context);
    }

    public void insertFood(PopularDomain item) {
        ArrayList<PopularDomain> listpop = getListCart();
        boolean existAlready = false;
        int n = 0;
        for (int i = 0; i < listpop.size(); i++) {
            if (listpop.get(i).getTitle().equals(item.getTitle())) {
                existAlready = true;
                n = i;
                break;
            }
        }
        if(existAlready){
            listpop.get(n).setNumberInCart(item.getNumberInCart());
        }else{
            listpop.add(item);
        }
        tinyDB.putListObject("CartList",listpop);
        Toast.makeText(context, "Added to your Cart", Toast.LENGTH_SHORT).show();
    }

    public ArrayList<PopularDomain> getListCart() {
        return tinyDB.getListObject("CartList");
    }

    public Double getTotalFee(){
        ArrayList<PopularDomain> listItem=getListCart();
        double fee=0;
        for (int i = 0; i < listItem.size(); i++) {
            fee=fee+(listItem.get(i).getPrice()*listItem.get(i).getNumberInCart());
        }
        return fee;
    }

    public void minusNumberItem(ArrayList<PopularDomain> listItem,int position,ChangeNumberItemsListener changeNumberItemsListener){
        PopularDomain item = listItem.get(position);

        OSGProduct cartProduct = new OSGProduct(item.getId(), item.getTitle());
        cartProduct.price = (int) item.getPrice();

        if(listItem.get(position).getNumberInCart()==1){
            listItem.remove(position);
        }else{
            listItem.get(position).setNumberInCart(listItem.get(position).getNumberInCart()-1);
        }
        // OmniSegment SDK
        // Wiki: https://github.com/beBit-tech/bebit-tech-android-app-sdk/wiki/Send-Action-(Event)-Examples#remove-from-cart
        // Purpose: Track when users remove items from cart to understand cart abandonment patterns
        OSGEvent cartEvent = OSGEvent.removeFromCart(Arrays.asList(cartProduct));
        cartEvent.location = "app://cart";
        cartEvent.locationTitle = "Cart Page";
        OmniSegment.trackEvent(cartEvent);

        tinyDB.putListObject("CartList",listItem);
        changeNumberItemsListener.change();
    }
    public  void plusNumberItem(ArrayList<PopularDomain> listItem,int position,ChangeNumberItemsListener changeNumberItemsListener){
        listItem.get(position).setNumberInCart(listItem.get(position).getNumberInCart()+1);
        tinyDB.putListObject("CartList",listItem);
        changeNumberItemsListener.change();
    }
}
