package com.bebit.testApp.Domain;

import java.io.Serializable;
import java.util.UUID;

public class PopularDomain implements Serializable {
    private String id;
    private String title;
    private String description;
    private String picUrl;
    private int review;
    private double score;
    private int numberInCart;
    private double price;

    public PopularDomain(String title, String description, String picUrl, int review, double score,  double price) {
        this.id = UUID.randomUUID().toString();
        this.title = title;
        this.description = description;
        this.picUrl = picUrl;
        this.review = review;
        this.score = score;

        this.price = price;
    }

    public String getId() {
        return id;
    }
    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getPicUrl() {
        return picUrl;
    }

    public void setPicUrl(String picUrl) {
        this.picUrl = picUrl;
    }

    public int getReview() {
        return review;
    }

    public void setReview(int review) {
        this.review = review;
    }

    public double getScore() {
        return score;
    }

    public void setScore(double score) {
        this.score = score;
    }

    public int getNumberInCart() {
        return numberInCart;
    }

    public void setNumberInCart(int numberInCart) {
        this.numberInCart = numberInCart;
    }

    public double getPrice() {
        return price;
    }

    public void setPrice(double price) {
        this.price = price;
    }
}
