class ProductListResponse {
  int? numOfPages;
  List<ProductResponse>? data;

  ProductListResponse({this.numOfPages, this.data});

  factory ProductListResponse.fromJson(Map<String, dynamic> json) {
    return ProductListResponse(
      numOfPages: json['num_of_pages'],
      data: json['data'] != null
          ? (json['data'] as List)
              .map((i) => ProductResponse.fromJson(i))
              .toList()
          : null,
    );
  }
}

class ProductResponse {
  int? id;
  var name;
  String? slug;
  String? permalink;
  String? dateCreated;
  String? dateModified;
  String? type;
  String? status;
  bool? featured;
  String? catalogVisibility;
  String? description;
  String? shortDescription;
  String? sku;
  String? price;
  String? regularPrice;
  String? salePrice;
  String? dateOnSaleFrom;
  String? dateOnSaleTo;
  String? priceHtml;
  bool? onSale;
  bool? purchasable;
  int? totalSales;
  bool? virtual;
  bool? downloadable;
  List<Null>? downloads;
  int? downloadLimit;
  int? downloadExpiry;
  String? downloadType;
  String? externalUrl;
  String? buttonText;
  String? taxStatus;
  String? taxClass;
  bool? manageStock;
  int? stockQuantity;
  bool? inStock;
  String? backorders;
  bool? backordersAllowed;
  bool? backOrdered;
  bool? soldIndividually;
  String? weight;
  Dimensions? dimensions;
  bool? shippingRequired;
  bool? shippingTaxable;
  String? shippingClass;
  int? shippingClassId;
  bool? reviewsAllowed;
  String? averageRating;
  int? ratingCount;
  List<int>? relatedIds;
  List<int>? upSellIds;
  List<int>? crossSellIds;
  int? parentId;
  String? purchaseNote;
  List<Categories>? categories;
  List<Null>? tags;
  List<Images>? images;
  List<Attributes>? attributes;
  List<Null>? defaultAttributes;
  List<Null>? variations;
  List<Null>? groupedProducts;
  List<UpsellId>? upSellId;
  int? menuOrder;
  bool? isAddedCart;
  bool? isAddedWishList;
  bool mIsInWishList = false;
  Store? store;

  ProductResponse(
      {this.id,
      this.name,
      this.slug,
      this.permalink,
      this.dateCreated,
      this.dateModified,
      this.type,
      this.status,
      this.featured,
      this.catalogVisibility,
      this.description,
      this.shortDescription,
      this.sku,
      this.price,
      this.regularPrice,
      this.salePrice,
      this.dateOnSaleFrom,
      this.dateOnSaleTo,
      this.priceHtml,
      this.onSale,
      this.purchasable,
      this.totalSales,
      this.virtual,
      this.downloadable,
      this.downloads,
      this.downloadLimit,
      this.downloadExpiry,
      this.downloadType,
      this.externalUrl,
      this.buttonText,
      this.taxStatus,
      this.taxClass,
      this.manageStock,
      this.stockQuantity,
      this.inStock,
      this.backorders,
      this.backordersAllowed,
      this.backOrdered,
      this.soldIndividually,
      this.weight,
      this.dimensions,
      this.shippingRequired,
      this.shippingTaxable,
      this.shippingClass,
      this.shippingClassId,
      this.reviewsAllowed,
      this.averageRating,
      this.ratingCount,
      this.relatedIds,
      this.upSellIds,
      this.crossSellIds,
      this.parentId,
      this.purchaseNote,
      this.categories,
      this.tags,
      this.images,
      this.attributes,
      this.defaultAttributes,
      this.variations,
      this.groupedProducts,
      this.upSellId,
      this.menuOrder,
      this.isAddedCart,
      this.isAddedWishList});

  ProductResponse.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    slug = json['slug'];
    permalink = json['permalink'];
    dateCreated = json['date_created'];
    dateModified = json['date_modified'];
    type = json['type'];
    status = json['status'];
    featured = json['featured'];
    catalogVisibility = json['catalog_visibility'];
    description = json['description'];
    shortDescription = json['short_description'];
    sku = json['sku'];
    price = json['price'];
    regularPrice = json['regular_price'];
    salePrice = json['sale_price'];
    dateOnSaleFrom = json['date_on_sale_from'];
    dateOnSaleTo = json['date_on_sale_to'];
    priceHtml = json['price_html'];
    onSale = json['on_sale'];
    purchasable = json['purchasable'];
    totalSales = json['total_sales'];
    virtual = json['virtual'];
    downloadable = json['downloadable'];
//    if (json['downloads'] != null) {
//      downloads = new List<Null>();
//      json['downloads'].forEach((v) {
//        downloads.add(new Null.fromJson(v));
//      });
//    }
    downloadLimit = json['download_limit'];
    downloadExpiry = json['download_expiry'];
    downloadType = json['download_type'];
    externalUrl = json['external_url'];
    buttonText = json['button_text'];
    taxStatus = json['tax_status'];
    taxClass = json['tax_class'];
    manageStock = json['manage_stock'];
    stockQuantity = json['stock_quantity'];
    inStock = json['in_stock'];
    backorders = json['backorders'];
    backordersAllowed = json['backorders_allowed'];
    backOrdered = json['backordered'];
    soldIndividually = json['sold_individually'];
    weight = json['weight'];
    dimensions = json['dimensions'] != null
        ? new Dimensions.fromJson(json['dimensions'])
        : null;
    shippingRequired = json['shipping_required'];
    shippingTaxable = json['shipping_taxable'];
    shippingClass = json['shipping_class'];
    shippingClassId = json['shipping_class_id'];
    reviewsAllowed = json['reviews_allowed'];
    averageRating = json['average_rating'];
    ratingCount = json['rating_count'];
    relatedIds = json['related_ids'].cast<int>();
    upSellIds = json['upsell_ids'].cast<int>();
    crossSellIds = json['cross_sell_ids'].cast<int>();
    parentId = json['parent_id'];
    purchaseNote = json['purchase_note'];
    if (json['categories'] != null) {
      categories = <Categories>[];
      json['categories'].forEach((v) {
        categories!.add(new Categories.fromJson(v));
      });
    }
//    if (json['tags'] != null) {
//      tags = new List<Null>();
//      json['tags'].forEach((v) {
//        tags.add(new Null.fromJson(v));
//      });
//    }
    if (json['images'] != null) {
      images = <Images>[];
      json['images'].forEach((v) {
        images!.add(new Images.fromJson(v));
      });
    }
    if (json['attributes'] != null) {
      attributes = <Attributes>[];
      json['attributes'].forEach((v) {
        attributes!.add(new Attributes.fromJson(v));
      });
    }

    // if (json['upsell_id'] != null) {
    //   upSellId = <UpsellId>[];
    //   json['upsell_id'].forEach((v) {
    //     upSellId.add(new UpsellId.fromJson(v));
    //   });
    // }
    menuOrder = json['menu_order'];
    isAddedCart = json['is_added_cart'];
    isAddedWishList = json['is_added_wishlist'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['slug'] = this.slug;
    data['permalink'] = this.permalink;
    data['date_created'] = this.dateCreated;
    data['date_modified'] = this.dateModified;
    data['type'] = this.type;
    data['status'] = this.status;
    data['featured'] = this.featured;
    data['catalog_visibility'] = this.catalogVisibility;
    data['description'] = this.description;
    data['short_description'] = this.shortDescription;
    data['sku'] = this.sku;
    data['price'] = this.price;
    data['regular_price'] = this.regularPrice;
    data['sale_price'] = this.salePrice;
    data['date_on_sale_from'] = this.dateOnSaleFrom;
    data['date_on_sale_to'] = this.dateOnSaleTo;
    data['price_html'] = this.priceHtml;
    data['on_sale'] = this.onSale;
    data['purchasable'] = this.purchasable;
    data['total_sales'] = this.totalSales;
    data['virtual'] = this.virtual;
    data['downloadable'] = this.downloadable;
//    if (this.downloads != null) {
//      data['downloads'] = this.downloads.map((v) => v.toJson()).toList();
//    }
    data['download_limit'] = this.downloadLimit;
    data['download_expiry'] = this.downloadExpiry;
    data['download_type'] = this.downloadType;
    data['external_url'] = this.externalUrl;
    data['button_text'] = this.buttonText;
    data['tax_status'] = this.taxStatus;
    data['tax_class'] = this.taxClass;
    data['manage_stock'] = this.manageStock;
    data['stock_quantity'] = this.stockQuantity;
    data['in_stock'] = this.inStock;
    data['backorders'] = this.backorders;
    data['backorders_allowed'] = this.backordersAllowed;
    data['backordered'] = this.backOrdered;
    data['sold_individually'] = this.soldIndividually;
    data['weight'] = this.weight;
    if (this.dimensions != null) {
      data['dimensions'] = this.dimensions!.toJson();
    }
    data['shipping_required'] = this.shippingRequired;
    data['shipping_taxable'] = this.shippingTaxable;
    data['shipping_class'] = this.shippingClass;
    data['shipping_class_id'] = this.shippingClassId;
    data['reviews_allowed'] = this.reviewsAllowed;
    data['average_rating'] = this.averageRating;
    data['rating_count'] = this.ratingCount;
    data['related_ids'] = this.relatedIds;
    data['upsell_ids'] = this.upSellIds;
    data['cross_sell_ids'] = this.crossSellIds;
    data['parent_id'] = this.parentId;
    data['purchase_note'] = this.purchaseNote;
    if (this.categories != null) {
      data['categories'] = this.categories!.map((v) => v.toJson()).toList();
    }
//    if (this.tags != null) {
//      data['tags'] = this.tags.map((v) => v.toJson()).toList();
//    }
    if (this.images != null) {
      data['images'] = this.images!.map((v) => v.toJson()).toList();
    }
    if (this.attributes != null) {
      data['attributes'] = this.attributes!.map((v) => v.toJson()).toList();
    }
//    if (this.defaultAttributes != null) {
//      data['default_attributes'] =
//          this.defaultAttributes.map((v) => v.toJson()).toList();
//    }
//    if (this.variations != null) {
//      data['variations'] = this.variations.map((v) => v.toJson()).toList();
//    }
//    if (this.groupedProducts != null) {
//      data['grouped_products'] =
//          this.groupedProducts.map((v) => v.toJson()).toList();
//    }
    if (this.upSellId != null) {
      data['upsell_id'] = this.upSellId!.map((v) => v.toJson()).toList();
    }
    data['menu_order'] = this.menuOrder;
    data['is_added_cart'] = this.isAddedCart;
    data['is_added_wishlist'] = this.isAddedWishList;
    return data;
  }
}

class Dimensions {
  String? length;
  String? width;
  String? height;

  Dimensions({this.length, this.width, this.height});

  Dimensions.fromJson(Map<String, dynamic> json) {
    length = json['length'];
    width = json['width'];
    height = json['height'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['length'] = this.length;
    data['width'] = this.width;
    data['height'] = this.height;
    return data;
  }
}

class Categories {
  int? id;
  String? name;
  String? slug;

  Categories({this.id, this.name, this.slug});

  Categories.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    slug = json['slug'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['slug'] = this.slug;
    return data;
  }
}

class Images {
  int? id;
  String? dateCreated;
  String? dateModified;
  String? src;
  String? name;
  String? alt;
  int? position;

  Images(
      {this.id,
      this.dateCreated,
      this.dateModified,
      this.src,
      this.name,
      this.alt,
      this.position});

  Images.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    dateCreated = json['date_created'];
    dateModified = json['date_modified'];
    src = json['src'];
    name = json['name'];
    alt = json['alt'];
    position = json['position'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['date_created'] = this.dateCreated;
    data['date_modified'] = this.dateModified;
    data['src'] = this.src;
    data['name'] = this.name;
    data['alt'] = this.alt;
    data['position'] = this.position;
    return data;
  }
}

class Attributes {
  int? id;
  String? name;
  int? position;
  bool? visible;
  bool? variation;
  List<String>? options;

  Attributes(
      {this.id,
      this.name,
      this.position,
      this.visible,
      this.variation,
      this.options});

  Attributes.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    position = json['position'];
    visible = json['visible'];
    variation = json['variation'];
    options = json['options'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['position'] = this.position;
    data['visible'] = this.visible;
    data['variation'] = this.variation;
    data['options'] = this.options;
    return data;
  }
}

class UpsellId {
  int? id;
  String? name;
  String? slug;
  String? price;
  String? regularPrice;
  String? salePrice;
  List<Images>? images;

  UpsellId(
      {this.id,
      this.name,
      this.slug,
      this.price,
      this.regularPrice,
      this.salePrice,
      this.images});

  UpsellId.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    slug = json['slug'];
    price = json['price'];
    regularPrice = json['regular_price'];
    salePrice = json['sale_price'];
    if (json['images'] != null) {
      images = <Images>[];
      json['images'].forEach((v) {
        images!.add(new Images.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['slug'] = this.slug;
    data['price'] = this.price;
    data['regular_price'] = this.regularPrice;
    data['sale_price'] = this.salePrice;
    if (this.images != null) {
      data['images'] = this.images!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
class Store {
    Address? address;
    String? id;
    String? name;
    String? shopName;
    String? url;

    Store({this.address, this.id, this.name, this.shopName, this.url});

    factory Store.fromJson(Map<String, dynamic> json) {
        return Store(
            address: json['address'] != null ? Address.fromJson(json['address']) : null, 
            id: json['id'], 
            name: json['name'], 
            shopName: json['shop_name'], 
            url: json['url'], 
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['id'] = this.id;
        data['name'] = this.name;
        data['shop_name'] = this.shopName;
        data['url'] = this.url;
        if (this.address != null) {
            data['address'] = this.address!.toJson();
        }
        return data;
    }
}

class VendorResponse {
  int? id;
  String? login;
  String? firstName;
  String? lastName;
  String? niceName;
  String? displayName;
  String? email;
  String? url;
  String? registered;
  String? status;
  List<String>? roles;
  Allcaps? allcaps;
  String? timezoneString;
  String? gmtOffset;
  Shop? shop;
  Address? address;
  Social? social;
  Payment? payment;
  String? messageToBuyers;
  int? ratingCount;
  String? avgRating;
  String? vendorProfile;

  VendorResponse(
      {this.id,
        this.login,
        this.firstName,
        this.lastName,
        this.niceName,
        this.displayName,
        this.email,
        this.url,
        this.registered,
        this.status,
        this.roles,
        this.allcaps,
        this.timezoneString,
        this.gmtOffset,
        this.shop,
        this.address,
        this.social,
        this.payment,
        this.messageToBuyers,
        this.ratingCount,
        this.avgRating,
        this.vendorProfile,
       });

  VendorResponse.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    login = json['login'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    niceName = json['nice_name'];
    displayName = json['display_name'];
    email = json['email'];
    url = json['url'];
    registered = json['registered'];
    status = json['status'];
    roles = json['roles'].cast<String>();
    allcaps =
    json['allcaps'] != null ? new Allcaps.fromJson(json['allcaps']) : null;
    timezoneString = json['timezone_string'];
    gmtOffset = json['gmt_offset'];
    shop = json['shop'] != null ? new Shop.fromJson(json['shop']) : null;
    address =
    json['address'] != null ? new Address.fromJson(json['address']) : null;
    social =
    json['social'] != null ? new Social.fromJson(json['social']) : null;
    payment =
    json['payment'] != null ? new Payment.fromJson(json['payment']) : null;
    messageToBuyers = json['message_to_buyers'];
    ratingCount = json['rating_count'];
    avgRating = json['avg_rating'];
    vendorProfile = json['vendor_profile'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['login'] = this.login;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['nice_name'] = this.niceName;
    data['display_name'] = this.displayName;
    data['email'] = this.email;
    data['url'] = this.url;
    data['registered'] = this.registered;
    data['status'] = this.status;
    data['roles'] = this.roles;
    if (this.allcaps != null) {
      data['allcaps'] = this.allcaps!.toJson();
    }
    data['timezone_string'] = this.timezoneString;
    data['gmt_offset'] = this.gmtOffset;
    if (this.shop != null) {
      data['shop'] = this.shop!.toJson();
    }
    if (this.address != null) {
      data['address'] = this.address!.toJson();
    }
    if (this.social != null) {
      data['social'] = this.social!.toJson();
    }
    if (this.payment != null) {
      data['payment'] = this.payment!.toJson();
    }
    data['message_to_buyers'] = this.messageToBuyers;
    data['rating_count'] = this.ratingCount;
    data['avg_rating'] = this.avgRating;
    data['vendor_profile'] = this.vendorProfile;
    return data;
  }
}

class Allcaps {
  bool? read;
  bool? manageProduct;
  bool? editPost;
  bool? editPosts;
  bool? deletePosts;
  bool? viewWoocommerceReports;
  bool? assignProductTerms;
  bool? uploadFiles;
  bool? readProduct;
  bool? readShopCoupon;
  bool? editShopOrders;
  bool? editProduct;
  bool? deleteProduct;
  bool? editProducts;
  bool? deleteProducts;
  bool? dcVendor;

  Allcaps(
      {this.read,
        this.manageProduct,
        this.editPost,
        this.editPosts,
        this.deletePosts,
        this.viewWoocommerceReports,
        this.assignProductTerms,
        this.uploadFiles,
        this.readProduct,
        this.readShopCoupon,
        this.editShopOrders,
        this.editProduct,
        this.deleteProduct,
        this.editProducts,
        this.deleteProducts,
        this.dcVendor});

  Allcaps.fromJson(Map<String, dynamic> json) {
    read = json['read'];
    manageProduct = json['manage_product'];
    editPost = json['edit_post'];
    editPosts = json['edit_posts'];
    deletePosts = json['delete_posts'];
    viewWoocommerceReports = json['view_woocommerce_reports'];
    assignProductTerms = json['assign_product_terms'];
    uploadFiles = json['upload_files'];
    readProduct = json['read_product'];
    readShopCoupon = json['read_shop_coupon'];
    editShopOrders = json['edit_shop_orders'];
    editProduct = json['edit_product'];
    deleteProduct = json['delete_product'];
    editProducts = json['edit_products'];
    deleteProducts = json['delete_products'];
    dcVendor = json['dc_vendor'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['read'] = this.read;
    data['manage_product'] = this.manageProduct;
    data['edit_post'] = this.editPost;
    data['edit_posts'] = this.editPosts;
    data['delete_posts'] = this.deletePosts;
    data['view_woocommerce_reports'] = this.viewWoocommerceReports;
    data['assign_product_terms'] = this.assignProductTerms;
    data['upload_files'] = this.uploadFiles;
    data['read_product'] = this.readProduct;
    data['read_shop_coupon'] = this.readShopCoupon;
    data['edit_shop_orders'] = this.editShopOrders;
    data['edit_product'] = this.editProduct;
    data['delete_product'] = this.deleteProduct;
    data['edit_products'] = this.editProducts;
    data['delete_products'] = this.deleteProducts;
    data['dc_vendor'] = this.dcVendor;
    return data;
  }
}

class Shop {
  String? url;
  String? title;
  String? slug;
  String? description;
  String? image;
  String? banner;

  Shop(
      {this.url,
        this.title,
        this.slug,
        this.description,
        this.image,
        this.banner});

  Shop.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    title = json['title'];
    slug = json['slug'];
    description = json['description'];
    image = json['image'];
    banner = json['banner'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['url'] = this.url;
    data['title'] = this.title;
    data['slug'] = this.slug;
    data['description'] = this.description;
    data['image'] = this.image;
    data['banner'] = this.banner;
    return data;
  }
}

class Address {
  String? address1;
  String? address2;
  String? city;
  String? state;
  String? country;
  String? postcode;
  String? phone;

  Address(
      {this.address1,
        this.address2,
        this.city,
        this.state,
        this.country,
        this.postcode,
        this.phone});

  Address.fromJson(Map<String, dynamic> json) {
    address1 = json['address_1'];
    address2 = json['address_2'];
    city = json['city'];
    state = json['state'];
    country = json['country'];
    postcode = json['postcode'];
    phone = json['phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['address_1'] = this.address1;
    data['address_2'] = this.address2;
    data['city'] = this.city;
    data['state'] = this.state;
    data['country'] = this.country;
    data['postcode'] = this.postcode;
    data['phone'] = this.phone;
    return data;
  }
}

class Social {
  String? facebook;
  String? twitter;
  String? googlePlus;
  String? linkdin;
  String? youtube;
  String? instagram;

  Social(
      {this.facebook,
        this.twitter,
        this.googlePlus,
        this.linkdin,
        this.youtube,
        this.instagram});

  Social.fromJson(Map<String, dynamic> json) {
    facebook = json['facebook'];
    twitter = json['twitter'];
    googlePlus = json['google_plus'];
    linkdin = json['linkdin'];
    youtube = json['youtube'];
    instagram = json['instagram'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['facebook'] = this.facebook;
    data['twitter'] = this.twitter;
    data['google_plus'] = this.googlePlus;
    data['linkdin'] = this.linkdin;
    data['youtube'] = this.youtube;
    data['instagram'] = this.instagram;
    return data;
  }
}

class Payment {
  String? paymentMode;
  String? bankAccountType;
  String? bankName;
  String? bankAccountNumber;
  String? bankAddress;
  String? accountHolderName;
  String? abaRoutingNumber;
  String? destinationCurrency;
  String? iban;
  String? paypalEmail;

  Payment(
      {this.paymentMode,
        this.bankAccountType,
        this.bankName,
        this.bankAccountNumber,
        this.bankAddress,
        this.accountHolderName,
        this.abaRoutingNumber,
        this.destinationCurrency,
        this.iban,
        this.paypalEmail});

  Payment.fromJson(Map<String, dynamic> json) {
    paymentMode = json['payment_mode'];
    bankAccountType = json['bank_account_type'];
    bankName = json['bank_name'];
    bankAccountNumber = json['bank_account_number'];
    bankAddress = json['bank_address'];
    accountHolderName = json['account_holder_name'];
    abaRoutingNumber = json['aba_routing_number'];
    destinationCurrency = json['destination_currency'];
    iban = json['iban'];
    paypalEmail = json['paypal_email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['payment_mode'] = this.paymentMode;
    data['bank_account_type'] = this.bankAccountType;
    data['bank_name'] = this.bankName;
    data['bank_account_number'] = this.bankAccountNumber;
    data['bank_address'] = this.bankAddress;
    data['account_holder_name'] = this.accountHolderName;
    data['aba_routing_number'] = this.abaRoutingNumber;
    data['destination_currency'] = this.destinationCurrency;
    data['iban'] = this.iban;
    data['paypal_email'] = this.paypalEmail;
    return data;
  }
}








