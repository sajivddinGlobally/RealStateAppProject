import 'dart:io';
import 'package:dio/dio.dart';
import 'package:realstate/Model/Body/CreatePropertyBodyModel.dart';
import 'package:realstate/Model/Body/UpdatePropertyBodyModel.dart';
import 'package:realstate/Model/Body/checkSlotBodyModel.dart';
import 'package:realstate/Model/Body/homeGerServiceCategoryByIdModel.dart';
import 'package:realstate/Model/Body/userResister.dart';
import 'package:realstate/Model/checkSlotResModel.dart';
import 'package:realstate/Model/contactUsBodyModel.dart';
import 'package:realstate/Model/contactUsResModel.dart';
import 'package:realstate/Model/editProfileBodyModel.dart';
import 'package:realstate/Model/editProfileResModel.dart';
import 'package:realstate/Model/getLikeProperyResModel.dart';
import 'package:realstate/Model/getMyPropertyBodyModel.dart';
import 'package:realstate/Model/getMyPropertyDetailsResModel.dart';
import 'package:realstate/Model/getMyPropertyResModel.dart';
import 'package:realstate/Model/homeBookingServiceBodyModel.dart';
import 'package:realstate/Model/homeBookingServiceResModel.dart';
import 'package:realstate/Model/homeGetServiceCateogryModel.dart';
import 'package:realstate/Model/likePropertyBodyModel.dart';
import 'package:realstate/Model/likePropertyResModel.dart';
import 'package:realstate/Model/loanQueryBodyModel.dart';
import 'package:realstate/Model/loanQueryResModel.dart';
import 'package:realstate/Model/loanServiceResModel.dart';
import 'package:realstate/Model/loginWithPhoneBodyModel.dart';
import 'package:realstate/Model/myBookingServiceRequestResModel.dart';
import 'package:realstate/Model/registerResModel.dart';
import 'package:realstate/Model/saveContactInPropertyBodyModel.dart';
import 'package:realstate/Model/saveContactInPropertyResModel.dart';
import 'package:realstate/Model/uploadImageResModel.dart';
import 'package:realstate/Model/userProfileResModel.dart';
import 'package:realstate/Model/verfiyServiceAgenetBodyModel.dart';
import 'package:realstate/Model/verifyBodyModel.dart';
import 'package:realstate/Model/verifyResModel.dart';
import 'package:realstate/Model/verifyServiceAgenetResModel.dart';
import 'package:retrofit/retrofit.dart';
import '../../Model/Body/PropertyListBodyModel.dart';
import '../../Model/CityResponseModel.dart';
import '../../Model/CreatePropertyResponseModel.dart';
import '../../Model/GetLoanQueryModel.dart';
import '../../Model/MultipleImgaeResponseModel.dart';
import '../../Model/SavedModel.dart';
import '../../Model/getPropertyResponsemodel.dart';

part 'api.state.g.dart';

@RestApi(baseUrl: 'https://api.propertyleinnovation.com/api/v1')
// @RestApi(baseUrl: 'http://192.168.1.43:9999/api/v1')
abstract class APIStateNetwork {
  factory APIStateNetwork(Dio dio, {String baseUrl}) = _APIStateNetwork;

  @POST('/user/sell-property')
  Future<CreatePropertyResponseModel> createProperty(
    @Body() CreatePropertyBodyModel body,
  );

  @POST('/user/updateProperty')
  Future<CreatePropertyResponseModel> updateProperty(
    @Body() UpdatePropertyBodyModel body,
  );

  @POST('/user/userRegister')
  Future<RegisterResModel> userRegister(@Body() UserResisterBodyModel body);

  @POST("/user/verifyOtp")
  Future<VerifyResModel> verifyUser(@Body() VerifyBodyModel body);

  @POST("/user/userLogin")
  Future<VerifyResModel> loginUser(@Body() LoginWithPhoneBodyModel body);

  @POST("/user/LoginRegister")
  Future<VerifyResModel> LoginRegister(
    @Body() LoginWithPhoneResisterBodyModel body,
  );

  @POST("/user/userProfile")
  Future<UserProfileResModel> userProfile();

  @MultiPart()
  @POST("/uploadImage")
  Future<UploadImageResModel> uploadImage(@Part(name: "file") File file);

  @MultiPart()
  @POST("/uploadMultipleImages")
  Future<MultipleImageUploadResponse> uploadImageMultiple(
    @Part(name: "file") List<File> file,
  );

  @POST("/user/userUpdate")
  Future<EditProfileResModel> editProfile(@Body() EditProfileBodyModel body);

  @POST("/user/getServiceCategory")
  Future<HomeGetServiceCategoryModel> homeServiceCategory();

  @POST("/user/getServiceCategoryById")
  Future<HomeGetServiceCategoryById> homeServiceCategoryById(
    @Field("id") String id,
  );

  @POST("/user/getCityList")
  Future<CityResponseModel> getCityList();

  @POST("/user/getLoanList")
  Future<LoanServiceResModel> fetchAllLoanService(
    @Body() LoanServiceBodyModel body,
  );

  @POST("/user/checkSlotAvailability")
  Future<CheckSlotResModel> checkSlotAvailability(
    @Body() CheckSlotBodyModel body,
  );

  @POST("/user/get-list")
  Future<PropertyGetReponseModel> getListProperty(
    @Body() PropertyListBodyModel body,
  );

  @POST("/user/loanQuery")
  Future<LoanQueryResModel> loanQuery(@Body() LoanQueryBodyModel body);

  @POST("/user/contact-us")
  Future<ContactUsResModel> contactUs(@Body() ContactUsBodyModel body);

  @POST("/user/getMyProperty")
  Future<GetMyPropertyResModel> getMyProperty();

  @POST("/user/getMyPropertyContantList")
  Future<SavedListModel> getMyPropertyContantList();

  @POST("/user/myLoanQuery")
  Future<GetLoanQueryModel> myLoanQuery();

  @POST("/user/get-property-by-id")
  Future<GetMyPropertyDetailsResModel> getMyPropertyDetails(
    @Body() GetMyPropertyDetailsBodyModel body,
  );

  @POST("/user/saveContactInProperty")
  Future<SaveContactInPropertyResModel> saveContactInProperty(
    @Body() SaveContactInPropertyBodyModel body,
  );

  @POST("/user/togelProperties")
  Future<LikePropertyResModel> likeProperties(
    @Body() LikePropertyBodyModel body,
  );

  @POST("/user/getLikeProperties")
  Future<GetLikePropertyResModel> getLikeProperty();

  @POST("/user/BookService")
  Future<HomeBookingServiceResModel> bookHomeService(
    @Body() HomeBookingServiceBodyModel body,
  );

  @POST("/user/BookingServices")
  Future<MyBookingServiceRequestResModel> MyRequestBookingService();

  @POST("/user/verifyServiceAgent")
  Future<VerifyServiceAgentResModel> verifyServiceAgent(
    @Body() VerifyServiceAgentBodyModel body,
  );

  @POST("/user/createServiceRating")
  Future<dynamic> createServiceRating(
      @Body() Map<String, dynamic> body,
      );
}
