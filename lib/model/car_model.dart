class CarModel {
  final int id;
  final int userId;
  final String sellType;
  final int exteriorColorId;
  final int interiorColorId;
  final String price;
  final int condition;
  final int usedFrom;
  final String location;
  final int status;
  final String km;
  final String address;
  final int cityId;
  final int subdistrictId;
  final String oldPrice;
  final String description;
  final String lisencePlate;
  final String createdAt;
  final String updatedAt;
  final String deletedAt;
  final UserCarModel user;
  final List<PurchaseCarModel> purchase;
  final List<GaleryCarModel> exteriorGalery;
  final List<GaleryCarModel> interiorGalery;
  final String brandName;
  final String modelName;
  final String groupModelName;

  CarModel({
    required this.id,
    required this.userId,
    required this.sellType,
    required this.exteriorColorId,
    required this.interiorColorId,
    required this.price,
    required this.condition,
    required this.usedFrom,
    required this.location,
    required this.status,
    required this.km,
    required this.address,
    required this.cityId,
    required this.subdistrictId,
    required this.oldPrice,
    required this.description,
    required this.lisencePlate,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
    required this.user,
    required this.purchase,
    required this.exteriorGalery,
    required this.interiorGalery,
    required this.brandName,
    required this.modelName,
    required this.groupModelName,
  });

  factory CarModel.fromJson(Map<String, dynamic> x) {
    return CarModel(
      id: x['id'] ?? 0,
      userId: x['userId'] ?? 0,
      sellType: x['sellType'] ?? "",
      exteriorColorId: x['exteriorColorId'] ?? 0,
      interiorColorId: x['interiorColorId'] ?? 0,
      price: x['price'] ?? "",
      condition: x['condition'] ?? 0,
      usedFrom: x['usedFrom'] ?? 0,
      location: x['location'] ?? "",
      status: x['status'] ?? 0,
      km: x['km'] ?? "",
      address: x['address'] ?? "",
      cityId: x['cityId'] ?? 0,
      subdistrictId: x['subdistrictId'] ?? 0,
      oldPrice: x['oldPrice'] ?? "",
      description: x['description'] ?? "",
      lisencePlate: x['lisencePlate'] ?? "",
      createdAt: x['createdAt'] ?? "",
      updatedAt: x['updatedAt'] ?? "",
      deletedAt: x['deletedAt'] ?? "",
      user: UserCarModel.fromJson(x['user']),
      purchase: List<PurchaseCarModel>.from(
          x['purchase'].map((x) => PurchaseCarModel.fromJson(x))),
      exteriorGalery: List<GaleryCarModel>.from(
          x['exteriorGalery'].map((x) => GaleryCarModel.fromJson(x))),
      interiorGalery: List<GaleryCarModel>.from(
          x['interiorGalery'].map((x) => GaleryCarModel.fromJson(x))),
      brandName: x['brandName'] ?? "",
      modelName: x['modelName'] ?? "",
      groupModelName: x['groupModelName'] ?? "",
    );
  }
}

class UserCarModel {
  final int id;
  final String phone;
  final String email;
  final String emailValidAt;
  final int type;
  final int companyType;
  final int userTypeDetailId;
  final int profileImageId;
  final String name;
  final String address;
  final int cityId;
  final int subdistrictId;
  final int fotoIdentitas;
  final String noKTP;
  final int picId;
  final String latLong;
  final String myRefferalCode;

  UserCarModel({
    required this.id,
    required this.phone,
    required this.email,
    required this.emailValidAt,
    required this.type,
    required this.companyType,
    required this.userTypeDetailId,
    required this.profileImageId,
    required this.name,
    required this.address,
    required this.cityId,
    required this.subdistrictId,
    required this.fotoIdentitas,
    required this.noKTP,
    required this.picId,
    required this.latLong,
    required this.myRefferalCode,
  });

  factory UserCarModel.fromJson(Map<String, dynamic> x) {
    return UserCarModel(
        id: x["id"] ?? 0,
        phone: x["phone"] ?? "",
        email: x["email"] ?? "",
        emailValidAt: x["emailValidAt"] ?? "",
        type: x["type"] ?? 0,
        companyType: x["companyType"] ?? 0,
        userTypeDetailId: x["userTypeDetailId"] ?? 0,
        profileImageId: x["profileImageId"] ?? 0,
        name: x["address"] ?? "",
        address: x["address"] ?? "",
        cityId: x["cityId"] ?? 0,
        subdistrictId: x["subdistrictId"] ?? 0,
        fotoIdentitas: x["fotoIdentitas"] ?? 0,
        noKTP: x["noKTP"] ?? "",
        picId: x["picId"] ?? 0,
        latLong: x["latLong"] ?? "",
        myRefferalCode: x["myRefferalCode"] ?? "");
  }
}

class PurchaseCarModel {
  final String price;
  final String purchaseDate;

  PurchaseCarModel({
    required this.price,
    required this.purchaseDate,
  });

  factory PurchaseCarModel.fromJson(Map<String, dynamic> x) {
    return PurchaseCarModel(
      price: x["price"] ?? "",
      purchaseDate: x["purchaseDate"] ?? "",
    );
  }
}

class GaleryCarModel {
  final int fileId;
  final FileCarModel file;

  GaleryCarModel({
    required this.fileId,
    required this.file,
  });

  factory GaleryCarModel.fromJson(Map<String, dynamic> x) {
    return GaleryCarModel(
      fileId: x["fileId"] ?? 0,
      file: FileCarModel.fromJson(x['file']),
    );
  }
}

class FileCarModel {
  String fileUrl = "";

  FileCarModel({required this.fileUrl});

  factory FileCarModel.fromJson(Map<String, dynamic> x) {
    return FileCarModel(fileUrl: x["fileUrl"] ?? "");
  }
}
