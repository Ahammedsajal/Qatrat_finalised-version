import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:customer/Provider/UserProvider.dart';
import 'package:customer/Screen/PaypalWebviewActivity.dart';
import 'package:customer/Screen/instamojo_webview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:my_fatoorah/my_fatoorah.dart';
import 'package:provider/provider.dart';
import '../Helper/ApiBaseHelper.dart';
import '../Helper/Color.dart';
import '../Helper/Constant.dart';
import '../Helper/Session.dart';
import '../Helper/String.dart';
import '../Helper/cart_var.dart';
import '../Model/Transaction_Model.dart';
import '../ui/styles/DesignConfig.dart';
import '../ui/styles/Validators.dart';
import '../ui/widgets/AppBtn.dart';
import '../ui/widgets/PaymentRadio.dart';
import '../ui/widgets/SimBtn.dart';
import '../ui/widgets/Stripe_Service.dart';
import '../utils/blured_router.dart';
import 'HomePage.dart';
import 'midtransWebView.dart';

class MyWalletScreen extends StatefulWidget {
  const MyWalletScreen({super.key});
  static route(RouteSettings settings) {
    return BlurredRouter(
      builder: (context) {
        return const MyWalletScreen();
      },
    );
  }

  @override
  State<StatefulWidget> createState() {
    return StateWallet();
  }
}

class StateWallet extends State<MyWalletScreen> with TickerProviderStateMixin {
  bool _isNetworkAvail = true;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formkey1 = GlobalKey<FormState>();
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  ScrollController controller = ScrollController();
  List<TransactionModel> tempList = [];
  List<TransactionModel> tempList1 = [];
  TextEditingController? amtC;
  TextEditingController? msgC;
  List<String?> paymentMethodList = [];
  List<String> paymentIconList = [
    'assets/images/paypal.svg',
    'assets/images/rozerpay.svg',
    'assets/images/flutterwave.svg',
    'assets/images/stripe.svg',
    'assets/images/paytm.svg',
    'assets/images/midtrans.svg',
    'assets/images/myfatoorah.svg',
    'assets/images/instamojo.svg',
  ];
  List<RadioModel> payModel = [];
  bool? paypal;
  bool? paumoney;
  bool? flutterwave;
  bool? stripe;
  bool? paytm;
  bool? midTrans;
  bool? myfatoorah;
  bool? instamojo;
  String? stripeId;
  String? stripeSecret;
  String? stripeMode = "test";
  String? stripeCurCode;
  String? paytmMerId;
  String? paytmMerKey;
  String? instamojoId;
 
  int? selectedMethod;
  String? payMethod;
  StateSetter? dialogState;
  bool _isProgress = false;
  List<TransactionModel> tranList = [];
  List<TransactionModel> withdTranList = [];
  int offset = 0;
  int offset1 = 0;
  int total = 0;
  int total1 = 0;
  bool isLoadingmore = true;
  bool _isLoading = true;
  bool payTesting = true;
  
  TextEditingController? amtC1;
  TextEditingController? bankDetailC;
  bool isWithdraw = false;
  @override
  void initState() {
    super.initState();
    selectedMethod = null;
    payMethod = null;
    Future.delayed(Duration.zero, () {
      paymentMethodList = [
        getTranslated(context, 'PAYPAL_LBL'),
        
        
        getTranslated(context, 'FLUTTERWAVE_LBL'),
        getTranslated(context, 'STRIPE_LBL'),
        getTranslated(context, 'PAYTM_LBL'),
        getTranslated(context, 'MIDTRANS_LBL'),
        getTranslated(context, 'MY_FATOORAH_LBL'),
        getTranslated(context, 'INSTAMOJO_LBL'),
      ];
      _getpaymentMethod();
    });
    controller.addListener(_scrollListener);
    buttonController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this,);
    buttonSqueezeanimation = Tween(
      begin: deviceWidth! * 0.7,
      end: 50.0,
    ).animate(CurvedAnimation(
      parent: buttonController!,
      curve: const Interval(
        0.0,
        0.150,
      ),
    ),);
    amtC = TextEditingController();
    msgC = TextEditingController();
    amtC1 = TextEditingController();
    bankDetailC = TextEditingController();
    getTransaction();
    
  }

  getAppBar() {
    return AppBar(
      elevation: 0,
      titleSpacing: 0,
      backgroundColor: Theme.of(context).colorScheme.white,
      leading: Builder(builder: (BuildContext context) {
        return Container(
          margin: const EdgeInsets.all(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(4),
            onTap: () => Navigator.of(context).pop(),
            child: Center(
              child: Icon(
                Icons.arrow_back_ios_rounded,
                color: Theme.of(context).colorScheme.primarytheme,
              ),
            ),
          ),
        );
      },),
      title: Text(
        getTranslated(context, 'MYWALLET')!,
        style: TextStyle(
            color: Theme.of(context).colorScheme.primarytheme,
            fontWeight: FontWeight.normal,),
      ),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsetsDirectional.only(end: 5.0),
          child: IconButton(
            onPressed: () {
              openFilterBottomSheet();
            },
            icon: Icon(
              Icons.filter_list,
              color: Theme.of(context).colorScheme.blackInverseInDarkTheme,
            ),
          ),
        ),
      ],
    );
  }

  void openFilterBottomSheet() {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40.0),
                topRight: Radius.circular(40.0),),),
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setStater) {
            return Wrap(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40.0),
                      topRight: Radius.circular(40.0),
                    ),
                  ),
                  padding: EdgeInsetsDirectional.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      bottomSheetHandle(context),
                      bottomsheetLabel('FILTER', context),
                      Flexible(
                        child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsetsDirectional.only(
                                    start: 20.0, end: 20.0, bottom: 15.0,),
                                child: Container(
                                  width: deviceWidth! - 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    color: Theme.of(context).colorScheme.gray,
                                  ),
                                  child: TextButton(
                                      child: Text(
                                          getTranslated(
                                              context, 'WAL_TRANS_LBL',)!,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium!
                                              .copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .fontColor
                                                      .withOpacity(0.5),),),
                                      onPressed: () {
                                        setState(() {
                                          isWithdraw = false;
                                          isLoadingmore = true;
                                          _isLoading = true;
                                          offset = 0;
                                          total = 0;
                                          tranList.clear();
                                          getTransaction();
                                        });
                                        Navigator.pop(context, 'option1');
                                      },),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsetsDirectional.only(
                                    start: 20.0, end: 20.0, bottom: 15.0,),
                                child: Container(
                                  width: deviceWidth! - 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    color: Theme.of(context).colorScheme.gray,
                                  ),
                                  child: TextButton(
                                      child: Text(
                                          getTranslated(
                                              context, 'WITHD_WAL_TRANS_LBL',)!,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium!
                                              .copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .fontColor
                                                      .withOpacity(0.5),),),
                                      onPressed: () {
                                        setState(() {
                                          isWithdraw = true;
                                          isLoadingmore = true;
                                          _isLoading = true;
                                          offset1 = 0;
                                          total1 = 0;
                                          withdTranList.clear();
                                        });
                                        getWithdrawalTransaction();
                                        Navigator.pop(context, 'option2');
                                      },),
                                ),
                              ),
                            ],),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },);
        },);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: getAppBar(),
        body: _isNetworkAvail
            ? _isLoading
                ? shimmer(context)
                : Stack(
                    children: <Widget>[
                      showContent(),
                      showCircularProgress(context, _isProgress,
                          Theme.of(context).colorScheme.primarytheme,),
                    ],
                  )
            : noInternet(context),);
  }

  withDrawDailog() {
    return dialogAnimate(
        context,
        AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(25.0)),),
          title: Text(getTranslated(context, 'SEND_WITHD_REQ_LBL')!,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(color: Theme.of(context).colorScheme.fontColor),),
          content: StatefulBuilder(builder: (context, StateSetter setStater) {
            return Form(
              key: _formkey1,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                      padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),),
                        height: 50,
                        child: TextFormField(
                          controller: amtC1,
                          keyboardType: TextInputType.number,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.fontColor,),
                          validator: (value) => validateField(
                              value!, getTranslated(context, 'FIELD_REQUIRED'),),
                          enabled: true,
                          textAlign: TextAlign.left,
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.gray,),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                            ),
                            contentPadding:
                                const EdgeInsets.fromLTRB(15.0, 10.0, 10, 10.0),
                            border: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                            ),
                            fillColor: Theme.of(context).colorScheme.gray,
                            filled: true,
                            isDense: true,
                            hintText: getTranslated(context, 'WIDTH_AMT_LBL'),
                            hintStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .fontColor
                                      .withOpacity(0.7),
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.normal,
                                ),
                          ),
                        ),
                      ),),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                      child: TextFormField(
                        controller: bankDetailC,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context).colorScheme.fontColor,),
                        validator: (value) => validateField(
                            value!, getTranslated(context, 'FIELD_REQUIRED'),),
                        enabled: true,
                        textAlign: TextAlign.left,
                        keyboardType: TextInputType.multiline,
                        maxLines: 7,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(17),
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.gray,),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(17),
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.gray,),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(17),
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.gray,),
                          ),
                          contentPadding:
                              const EdgeInsets.fromLTRB(15.0, 10.0, 10, 10.0),
                          fillColor: Theme.of(context).colorScheme.gray,
                          filled: true,
                          isDense: true,
                          hintText: getTranslated(context, 'BANK_DET_LBL'),
                          hintStyle:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .fontColor
                                        .withOpacity(0.7),
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w400,
                                    fontStyle: FontStyle.normal,
                                  ),
                        ),
                      ),),
                  Padding(
                      padding: const EdgeInsets.only(bottom: 15.0, top: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                  padding: const EdgeInsetsDirectional.only(
                                      top: 10, bottom: 10, start: 20, end: 20,),
                                  height: 40,
                                  alignment: FractionalOffset.center,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .fontColor,),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(5.0),),
                                  ),
                                  child: Text(getTranslated(context, 'CANCEL')!,
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall!
                                          .copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .fontColor,
                                            fontWeight: FontWeight.bold,
                                          ),),),),
                          CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                final form = _formkey1.currentState!;
                                if (form.validate()) {
                                  form.save();
                                  setStater(
                                    () {
                                      Navigator.pop(context);
                                    },
                                  );
                                  setState(() {
                                    _isProgress = true;
                                  });
                                  sendWithdrawRequest();
                                }
                              },
                              child: Container(
                                  padding: const EdgeInsetsDirectional.only(
                                      top: 10, bottom: 10, start: 25, end: 25,),
                                  height: 40,
                                  alignment: FractionalOffset.center,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primarytheme,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(5.0),),
                                  ),
                                  child: Text(getTranslated(context, 'SEND')!,
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall!
                                          .copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .white,
                                            fontWeight: FontWeight.bold,
                                          ),),),),
                        ],
                      ),),
                ],
              ),
            );
          },),
        ),);
  }

  Widget paymentItem(int index) {
    print("index****$index****$myfatoorah");
    if (index == 0 && paypal! ||
        
        index == 1 && flutterwave! ||
        index == 2 && stripe! ||
        index == 3 && paytm! ||
        index == 4 && midTrans! ||
        index == 5 && myfatoorah! ||
        index == 6 && instamojo! 
        ) {
      return InkWell(
        onTap: () {
          if (mounted) {
            dialogState!(() {
              selectedMethod = index;
              payMethod = paymentMethodList[selectedMethod!];
              print("paymethod****$payMethod");
              for (final element in payModel) {
                element.isSelected = false;
              }
              payModel[index].isSelected = true;
            });
          }
        },
        child: RadioItem(payModel[index]),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Future<void> sendWithdrawRequest() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        final parameter = {
          USER_ID: context.read<UserProvider>().userId,
          AMOUNT: amtC1!.text,
          PAYMENT_ADD: bankDetailC!.text,
        };
        final Response response = await post(
          setSendWithdrawReqApi,
          body: parameter,
          headers: headers,
        ).timeout(
          const Duration(
            seconds: timeOut,
          ),
        );
        final getdata = json.decode(response.body);
        final bool error = getdata["error"];
        final String msg = getdata["message"];
        if (!error) {
          amtC1!.clear();
          bankDetailC!.clear();
          final UserProvider userProvider =
              Provider.of<UserProvider>(context, listen: false);
          userProvider
              .setBalance(double.parse(getdata["data"]).toStringAsFixed(2));
        }
        if (mounted) {
          setState(() {
            _isProgress = false;
          });
        }
        setSnackbar(msg, context);
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, "somethingMSg")!, context);
        setState(
          () {
            _isProgress = false;
          },
        );
      }
    } else {
      if (mounted) {
        setState(
          () {
            _isNetworkAvail = false;
            _isProgress = false;
          },
        );
      }
    }
    return;
  }

  Future<void> sendRequest(String? txnId, String payMethod) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      final String orderId =
          "wallet-refill-user-${context.read<UserProvider>().userId}-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(900) + 100}";
      try {
        final parameter = {
          USER_ID: context.read<UserProvider>().userId,
          AMOUNT: amtC!.text,
          TRANS_TYPE: WALLET,
          TYPE: CREDIT,
          MSG: (msgC!.text == '' || msgC!.text.isEmpty)
              ? "Added through wallet"
              : msgC!.text,
          TXNID: txnId,
          ORDER_ID: orderId,
          STATUS: "Success",
          PAYMENT_METHOD: payMethod.toLowerCase(),
        };
        apiBaseHelper.postAPICall(addTransactionApi, parameter).then((getdata) {
          final bool error = getdata["error"];
          final String msg = getdata["message"];
          if (!error) {
            final UserProvider userProvider =
                Provider.of<UserProvider>(context, listen: false);
            userProvider.setBalance(double.parse(getdata["new_balance"])
                .toStringAsFixed(2)
                ,);
            isWithdraw = false;
            _isLoading = true;
            amtC!.clear();
            offset = 0;
            total = 0;
            tranList.clear();
            getTransaction();
          }
          setSnackbar(msg, context);
        }, onError: (error) {
          setSnackbar(error.toString(), context);
        },);
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, context);
        setState(() {
          _isProgress = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isNetworkAvail = false;
          _isProgress = false;
        });
      }
    }
    return;
  }

  _showDialog() async {
    bool payWarn = false;
    await dialogAnimate(context,
        StatefulBuilder(builder: (BuildContext context, StateSetter setStater) {
      dialogState = setStater;
      return AlertDialog(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5.0)),),
        content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 20.0, 0, 2.0),
                  child: Text(
                    getTranslated(context, 'ADD_MONEY')!,
                    style: Theme.of(this.context)
                        .textTheme
                        .titleMedium!
                        .copyWith(
                            color: Theme.of(context).colorScheme.fontColor,),
                  ),),
              Divider(color: Theme.of(context).colorScheme.lightBlack),
              Form(
                key: _formkey,
                child: Flexible(
                  child: SingleChildScrollView(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                        Padding(
                            padding:
                                const EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                            child: TextFormField(
                              style: Theme.of(this.context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .fontColor,
                                      fontWeight: FontWeight.normal,),
                              keyboardType: TextInputType.number,
                              validator: (val) => validateField(val!,
                                  getTranslated(context, 'FIELD_REQUIRED'),),
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              decoration: InputDecoration(
                                hintText: getTranslated(context, "AMOUNT"),
                                hintStyle: Theme.of(this.context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .fontColor,
                                        fontWeight: FontWeight.normal,),
                              ),
                              controller: amtC,
                            ),),
                        Padding(
                            padding:
                                const EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                            child: TextFormField(
                              style: Theme.of(this.context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .fontColor,
                                      fontWeight: FontWeight.normal,),
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              decoration: InputDecoration(
                                hintText: getTranslated(context, 'MSG'),
                                hintStyle: Theme.of(this.context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .lightBlack,
                                        fontWeight: FontWeight.normal,),
                              ),
                              controller: msgC,
                            ),),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20.0, 10, 20.0, 5),
                          child: Text(
                            getTranslated(context, 'SELECT_PAYMENT')!,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        const Divider(),
                        if (payWarn) Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0,),
                                child: Text(
                                  getTranslated(context, 'payWarning')!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(color: Colors.red),
                                ),
                              ) else const SizedBox.shrink(),
                        if (paypal == null) Center(
                                child: CircularProgressIndicator(
                                color:
                                    Theme.of(context).colorScheme.primarytheme,
                              ),) else Column(
                                children: getPayList(),),
                      ],),),
                ),
              ),
            ],),
        actions: <Widget>[
          TextButton(
              child: Text(
                getTranslated(context, 'CANCEL')!,
                style: Theme.of(this.context).textTheme.titleSmall!.copyWith(
                    color: Theme.of(context).colorScheme.lightBlack,
                    fontWeight: FontWeight.bold,),
              ),
              onPressed: () {
                Navigator.pop(context);
              },),
          TextButton(
              child: Text(
                getTranslated(context, 'ADD')!,
                style: Theme.of(this.context).textTheme.titleSmall!.copyWith(
                    color: Theme.of(context).colorScheme.fontColor,
                    fontWeight: FontWeight.bold,),
              ),
              onPressed: () {
                final form = _formkey.currentState!;
                print(
                    "paymethodtest****$payMethod****${form.validate()}*****${amtC!.text}",);
                if (form.validate() && amtC!.text != '0') {
                  print("if");
                  form.save();
                  if (payMethod == null) {
                    dialogState!(() {
                      payWarn = true;
                    });
                  } else {
                    print("else");
                    if (payMethod!.trim() ==
                        getTranslated(context, 'STRIPE_LBL')!.trim()) {
                      stripePayment(int.parse(amtC!.text));
                      Navigator.pop(context);
                    }   else if (payMethod ==
                        getTranslated(context, 'PAYTM_LBL')) {
                      paytmPayment(double.parse(amtC!.text));
                      Navigator.pop(context);
                    } else if (payMethod ==
                        getTranslated(context, 'PAYPAL_LBL')) {
                      paypalPayment(amtC!.text);
                    } else if (payMethod ==
                        getTranslated(context, 'FLUTTERWAVE_LBL')) {
                      flutterwavePayment(amtC!.text);
                      Navigator.pop(context);
                    } else if (payMethod ==
                        getTranslated(context, 'MIDTRANS_LBL')) {
                      doPaymentWithMidTrash(price: amtC!.text);
                      Navigator.pop(context);
                    } else if (payMethod ==
                        getTranslated(context, 'MY_FATOORAH_LBL')) {
                      print("here");
                      doMyFatoorah(price: amtC!.text, context: context);
                    } else if (payMethod ==
                        getTranslated(context, 'INSTAMOJO_LBL')) {
                      print('**************just about to call instamojo');
                      instamojoPayment(amtC!.text);
                      Navigator.pop(context);
                    } 
                  }
                }
              },),
        ],
      );
    },),);
  }

  Future<bool> addTransaction({
    required String tranId,
    required String status,
    required String msg,
    required String amount,
    required String paymentMethod,
  }) async {
    try {
      final parameter = {
        USER_ID: context.read<UserProvider>().userId,
        TXNID: tranId,
        AMOUNT: amount,
        STATUS: status,
        MSG: msg,
        ORDERID: tranId,
        PAYMENT_METHOD: paymentMethod,
        'transaction_type': 'wallet',
        'type': 'credit',
      };
      final getdata =
          await apiBaseHelper.postAPICall(addTransactionApi, parameter);
      return getdata['error'] == false;
    } catch (_) {
      return false;
    }
  }

  

  Future<void> instamojoPayment(String amount) async {
    try {
      final String orderId =
          'wallet-refill-user-${context.read<UserProvider>().userId}-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(900) + 100}';
      final parameter = {
        USER_ID: context.read<UserProvider>().userId,
        ORDER_ID: orderId,
        AMOUNT: amount,
      };
      apiBaseHelper.postAPICall(getInstamojoApi, parameter).then((getdata) {
        final bool error = getdata["error"];
        final String? msg = getdata["message"];
        if (!error) {
          if (getdata['data']['longurl'] != null &&
              getdata['data']['longurl'] != '') {
            final String? data = getdata['data']['longurl'];
            print("instamojo data url***$data");
            print('******response = $getdata');
            Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (BuildContext context) => InstamojoWebview(
                          url: data,
                          from: "wallet",
                          orderId: orderId,
                          updateWallet: updateWalletAmt,
                        ),),);
          } else {
            setSnackbar(getTranslated(context, 'somethingMSg')!, context);
          }
        } else {
          setSnackbar(msg!, context);
        }
      }, onError: (error) {
        setSnackbar(error.toString(), context);
      },);
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg')!, context);
    }
  }

  updateWalletAmt() async {
    await getUserWalletBalanceFromTransactionAPI();
  }

  doMyFatoorah({required String price, required BuildContext context}) async {
    try {
      const String tranId = '';
      final String orderID =
          'wallet-refill-user-${context.read<UserProvider>().userId}-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(900) + 100}';
      final String amount = price;
      print("url****$myfatoorahSuccessUrl");
      final String successUrl =
          '${myfatoorahSuccessUrl!}?txn_id=$tranId&order_id=$orderID&amount=$price';
      print("successUrl***$successUrl");
      print("test mode***$myfatoorahPaymentMode");
      final String errorUrl =
          '${myfatoorahErrorUrl!}?txn_id=$tranId&order_id=$orderID&amount=$price';
      print("errorUrl***$errorUrl");
      final String token = myfatoorahToken!;
      try {
        print("in try");
        Navigator.pop(context);
        final response = await MyFatoorah.startPayment(
          context: context,
          successChild: const SizedBox(
            width: 200,
            height: 200,
            child: Icon(
              Icons.done,
              size: 100,
              color: Colors.green,
            ),
          ),
          request: myfatoorahPaymentMode == 'test'
              ? MyfatoorahRequest.test(
                  userDefinedField: orderID,
                  currencyIso: () {
                    if (myfatoorahCountry == 'Kuwait') {
                      return Country.Kuwait;
                    } else if (myfatoorahCountry == 'UAE') {
                      return Country.UAE;
                    } else if (myfatoorahCountry == 'Egypt') {
                      return Country.Egypt;
                    } else if (myfatoorahCountry == 'Bahrain') {
                      return Country.Bahrain;
                    } else if (myfatoorahCountry == 'Jordan') {
                      return Country.Jordan;
                    } else if (myfatoorahCountry == 'Oman') {
                      return Country.Oman;
                    } else if (myfatoorahCountry == 'SaudiArabia') {
                      return Country.SaudiArabia;
                    } else if (myfatoorahCountry == 'SaudiArabia') {
                      return Country.Qatar;
                    }
                    return Country.SaudiArabia;
                  }(),
                  successUrl: successUrl,
                  errorUrl: errorUrl,
                  invoiceAmount: double.parse(amount),
                  language: () {
                    if (myfatoorahLanguage == 'english') {
                      return ApiLanguage.English;
                    }
                    return ApiLanguage.Arabic;
                  }(),
                  token: token,
                )
              : MyfatoorahRequest.live(
                  userDefinedField: orderID,
                  currencyIso: () {
                    if (myfatoorahCountry == 'Kuwait') {
                      return Country.Kuwait;
                    } else if (myfatoorahCountry == 'UAE') {
                      return Country.UAE;
                    } else if (myfatoorahCountry == 'Egypt') {
                      return Country.Egypt;
                    } else if (myfatoorahCountry == 'Bahrain') {
                      return Country.Bahrain;
                    } else if (myfatoorahCountry == 'Jordan') {
                      return Country.Jordan;
                    } else if (myfatoorahCountry == 'Oman') {
                      return Country.Oman;
                    } else if (myfatoorahCountry == 'SaudiArabia') {
                      return Country.SaudiArabia;
                    } else if (myfatoorahCountry == 'SaudiArabia') {
                      return Country.Qatar;
                    }
                    return Country.SaudiArabia;
                  }(),
                  successUrl: successUrl,
                  errorUrl: errorUrl,
                  invoiceAmount: double.parse(amount),
                  language: () {
                    if (myfatoorahLanguage == 'english') {
                      return ApiLanguage.English;
                    }
                    return ApiLanguage.Arabic;
                  }(),
                  token: token,
                ),
        );
        print("response***$response");
        if (response.status.toString() == 'PaymentStatus.Success') {
          await getUserWalletBalanceFromTransactionAPI();
          return {
            'error': false,
            'message': 'Transaction Successful',
            'status': true,
          };
        }
        if (response.status.toString() == 'PaymentStatus.Error') {
          return {'error': true, 'message': e.toString(), 'status': false};
        }
        if (response.status.toString() == 'PaymentStatus.None') {
          return {'error': true, 'message': e.toString(), 'status': false};
        }
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, context);
      }
      return {
        'error': false,
        'message': 'Transaction Successful',
        'status': true,
      };
    } catch (e) {
      return {'error': true, 'message': e.toString(), 'status': false};
    }
  }

  fetchUserCurrentBalance() async {
    try {
      final parameter = {
        LIMIT: '1',
        OFFSET: '0',
        USER_ID: context.read<UserProvider>().userId,
        TRANS_TYPE: WALLET,
      };
      final response =
          await ApiBaseHelper().postAPICall(getWalTranApi, parameter);
      if (!response['error']) {
        return response['balance'];
      }
      return '';
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg')!, context);
    }
  }

  midTransWebHook(String orderId) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      final parameter = {
        ORDER_ID: orderId,
      };
      final response =
          await ApiBaseHelper().postAPICall(midtransBebhookApi, parameter);
      return response['message'];
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg')!, context);
    }
  }

  Future<Map<String, dynamic>> doPaymentWithMidTrash({
    required String price,
  }) async {
    try {
      final String orderID =
          'wallet-refill-user-${context.read<UserProvider>().userId}-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(900) + 100}';
      try {
        final parameter = {
          AMOUNT: price,
          USER_ID: context.read<UserProvider>().userId,
          ORDER_ID: orderID,
        };
        apiBaseHelper.postAPICall(createMidtransTransactionApi, parameter).then(
          (getdata) {
            final bool error = getdata['error'];
            final String? msg = getdata['message'];
            if (!error) {
              final data = getdata['data'];
              final String redirectUrl = data['redirect_url'];
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (BuildContext context) => MidTrashWebview(
                    url: redirectUrl,
                    from: 'order',
                    orderId: orderID,
                  ),
                ),
              ).then(
                (value) async {
                  String msg = midTransWebHook(
                    orderID,
                  );
                  if (msg ==
                      'Order id is not matched with transaction order id.') {
                    msg = 'Transaction Failed...!';
                  }
                  await getUserWalletBalanceFromTransactionAPI();
                  setSnackbar(msg, context);
                  Navigator.pop(context, value);
                },
              );
            } else {
              setSnackbar(msg!, context);
            }
          },
          onError: (error) {
            setSnackbar(error.toString(), context);
          },
        );
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, context);
      }
      return {
        'error': false,
        'message': 'Transaction Successful',
        'status': true,
      };
    } catch (e) {
      return {'error': true, 'message': e.toString(), 'status': false};
    }
  }

  List<Widget> getPayList() {
    return paymentMethodList
        .asMap()
        .map(
          (index, element) => MapEntry(index, paymentItem(index)),
        )
        .values
        .toList();
  }

  Future<void> paypalPayment(String amt) async {
    final String orderId =
        "wallet-refill-user-${context.read<UserProvider>().userId}-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(900) + 100}";
    try {
      final parameter = {
        USER_ID: context.read<UserProvider>().userId,
        ORDER_ID: orderId,
        AMOUNT: amt,
      };
      apiBaseHelper.postAPICall(paypalTransactionApi, parameter).then(
          (getdata) {
        final bool error = getdata["error"];
        final String? msg = getdata["message"];
        if (!error) {
          final String? data = getdata["data"];
          Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (BuildContext context) => PaypalWebview(
                        url: data,
                        from: "wallet",
                      ),),).then((value) async {
            await getUserWalletBalanceFromTransactionAPI();
          });
        } else {
          setSnackbar(msg!, context);
        }
      }, onError: (error) {
        setSnackbar(error.toString(), context);
      },);
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg')!, context);
    }
  }

  Future<void> flutterwavePayment(String price) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        if (mounted) {
          setState(() {
            _isProgress = true;
          });
        }
        final parameter = {
          AMOUNT: price,
          USER_ID: context.read<UserProvider>().userId,
        };
        apiBaseHelper.postAPICall(flutterwaveApi, parameter).then((getdata) {
          final bool error = getdata["error"];
          final String? msg = getdata["message"];
          if (!error) {
            final data = getdata["link"];
            Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (BuildContext context) => PaypalWebview(
                          url: data,
                          from: "wallet",
                          amt: amtC!.text,
                          msg: msgC!.text,
                        ),),).then((value) async {
              await getUserWalletBalanceFromTransactionAPI();
            });
          } else {
            setSnackbar(msg!, context);
          }
          setState(() {
            _isProgress = false;
          });
        }, onError: (error) {
          setSnackbar(error.toString(), context);
        },);
      } on TimeoutException catch (_) {
        setState(() {
          _isProgress = false;
        });
        setSnackbar(getTranslated(context, 'somethingMSg')!, context);
      }
    } else {
      if (mounted) {
        setState(() {
          _isNetworkAvail = false;
        });
      }
    }
  }

  Future<void> paytmPayment(double price) async {
    String? paymentResponse;
    setState(() {
      _isProgress = true;
    });
    final String orderId = DateTime.now().millisecondsSinceEpoch.toString();
    final String callBackUrl =
        '${payTesting ? 'https://securegw-stage.paytm.in' : 'https://securegw.paytm.in'}/theia/paytmCallback?ORDER_ID=$orderId';
    final parameter = {
      AMOUNT: price.toString(),
      USER_ID: context.read<UserProvider>().userId,
      ORDER_ID: orderId,
    };
    
  }

  stripePayment(
    int price,
  ) async {
    if (mounted) {
      setState(() {
        _isProgress = true;
      });
    }
    final response = await StripeService.payWithPaymentSheet(
        amount: (price * 100).toString(),
        currency: stripeCurCode,
        from: 'wallet',
        context: context,);
    if (mounted) {
      setState(() {
        _isProgress = false;
      });
    }
    if (response.status == 'succeeded') {
      print("sucess ");
      setSnackbar(response.message!, context);
      if (mounted) {
        setState(() {
          _isProgress = false;
        });
      }
      await getUserWalletBalanceFromTransactionAPI();
    } else {
      print("unsucess ");
      setSnackbar(response.message!, context);
    }
    setSnackbar(response.message!, context);
  }

  

  String _getReference() {
    String platform;
    if (Platform.isIOS) {
      platform = 'iOS';
    } else {
      platform = 'Android';
    }
    return 'ChargedFrom${platform}_${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> _handlePaymentSuccess(String paymentGateway, String? paymentId) async {
  setSnackbar('Payment successful through $paymentGateway.', context);

  // Update user wallet balance or other required data
  await getUserWalletBalanceFromTransactionAPI();

  if (mounted) {
    setState(() {
      _isProgress = false;
    });
  }
}

void _handlePaymentError(String paymentGateway, String errorMessage) {
  setSnackbar('Payment failed via $paymentGateway: $errorMessage', context);

  if (mounted) {
    setState(() {
      _isProgress = false;
    });
  }
}

void _handleExternalWallet(String paymentGateway, String walletName) {
  // This can be expanded based on other payment gateway wallets (if any)
  print("External wallet used in $paymentGateway: $walletName");
  setSnackbar('Payment initiated through external wallet: $walletName', context);
}

  

  listItem1(int index) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.all(5.0),
      child: InkWell(
          borderRadius: BorderRadius.circular(4),
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            "${getTranslated(context, 'AMOUNT')!} : ${getPriceFormat(context, double.parse(withdTranList[index].amt!))!}",
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.fontColor,
                                fontWeight: FontWeight.bold,),
                          ),
                        ),
                        Text(withdTranList[index].dateCreated!),
                      ],
                    ),
                    const Divider(),
                    Text(
                        "${getTranslated(context, 'ID_LBL')!} : ${withdTranList[index].id!}",),
                    Text("Payment Address : ${withdTranList[index].payAdd!}"),
                  ],),),),
    );
  }

  listItem(int index) {
    Color back;
    if (tranList[index].type == "credit") {
      back = Colors.green;
    } else {
      back = Colors.red;
    }
    return Card(
      elevation: 0,
      margin: const EdgeInsets.all(5.0),
      child: InkWell(
          borderRadius: BorderRadius.circular(4),
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            "${getTranslated(context, 'AMOUNT')!} : ${getPriceFormat(context, double.parse(tranList[index].amt!))!}",
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.fontColor,
                                fontWeight: FontWeight.bold,),
                          ),
                        ),
                        Text(tranList[index].date!),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                            "${getTranslated(context, 'ID_LBL')!} : ${tranList[index].id!}",),
                        const Spacer(),
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 2,),
                          decoration: BoxDecoration(
                              color: back,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(4.0)),),
                          child: Text(
                            tranList[index].type!,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.white,),
                          ),
                        ),
                      ],
                    ),
                    if (tranList[index].msg != null &&
                            tranList[index].msg!.isNotEmpty) Text(
                            "${getTranslated(context, 'MSG')!} : ${tranList[index].msg!}",) else const SizedBox.shrink(),
                  ],),),),
    );
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {
      return;
    }
  }

  Widget noInternet(BuildContext context) {
    return SingleChildScrollView(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        noIntImage(),
        noIntText(context),
        noIntDec(context),
        AppBtn(
          title: getTranslated(context, 'TRY_AGAIN_INT_LBL'),
          btnAnim: buttonSqueezeanimation,
          btnCntrl: buttonController,
          onBtnSelected: () async {
            _playAnimation();
            Future.delayed(const Duration(seconds: 2)).then((_) async {
              _isNetworkAvail = await isNetworkAvailable();
              if (_isNetworkAvail) {
                if (!isWithdraw) {
                  getTransaction();
                } else {
                  getWithdrawalTransaction();
                }
              } else {
                await buttonController!.reverse();
                setState(() {});
              }
            });
          },
        ),
      ],),
    );
  }

  Future<void> getWithdrawalTransaction() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        final parameter = {
          LIMIT: perPage.toString(),
          OFFSET: offset1.toString(),
          USER_ID: context.read<UserProvider>().userId,
        };
        apiBaseHelper.postAPICall(getWithdrawReqApi, parameter).then((getdata) {
          final bool error = getdata["error"];
          if (!error) {
            total1 = int.parse(getdata["total"]);
            if (offset1 < total1) {
              tempList1.clear();
              final data = getdata["data"];
              tempList1 = (data as List)
                  .map((data) => TransactionModel.fromWithdrawJson(data))
                  .toList();
              withdTranList.addAll(tempList1);
              offset1 = offset1 + perPage;
            }
          } else {
            isLoadingmore = false;
          }
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        }, onError: (error) {
          setSnackbar(error.toString(), context);
        },);
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, context);
        setState(() {
          _isLoading = false;
          isLoadingmore = false;
        });
      }
    } else {
      setState(() {
        _isNetworkAvail = false;
      });
    }
    return;
  }

  Future<void> getTransaction() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        final parameter = {
          LIMIT: perPage.toString(),
          OFFSET: offset.toString(),
          USER_ID: context.read<UserProvider>().userId,
          TRANS_TYPE: WALLET,
        };
        apiBaseHelper.postAPICall(getWalTranApi, parameter).then((getdata) {
          final bool error = getdata["error"];
          if (!error) {
            total = int.parse(getdata["total"]);
            getdata.containsKey("balance");
            Provider.of<UserProvider>(context, listen: false)
                .setBalance(getdata["balance"]);
            if (offset < total) {
              tempList.clear();
              final data = getdata["data"];
              tempList = (data as List)
                  .map((data) => TransactionModel.fromJson(data))
                  .toList();
              tranList.addAll(tempList);
              offset = offset + perPage;
              setState(() {});
            }
          } else {
            isLoadingmore = false;
          }
          if (mounted) {
            setState(() {
              _isLoading = false;
              _isProgress = false;
            });
          }
        }, onError: (error) {
          setSnackbar(error.toString(), context);
        },);
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, context);
        setState(() {
          _isLoading = false;
          isLoadingmore = false;
        });
      }
    } else {
      setState(() {
        _isNetworkAvail = false;
      });
    }
    return;
  }

  Future<void> getUserWalletBalanceFromTransactionAPI() async {
    setState(() {
      _isLoading = true;
    });
    offset = 0;
    total = 0;
    tranList.clear();
    return getTransaction();
  }

  Future<void> getRequest() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        final parameter = {
          LIMIT: perPage.toString(),
          OFFSET: offset.toString(),
          USER_ID: context.read<UserProvider>().userId,
        };
        apiBaseHelper.postAPICall(getWalTranApi, parameter).then((getdata) {
          final bool error = getdata["error"];
          if (!error) {
            total = int.parse(getdata["total"]);
            if (offset < total) {
              tempList.clear();
              final data = getdata["data"];
              tempList = (data as List)
                  .map((data) => TransactionModel.fromReqJson(data))
                  .toList();
              tranList.addAll(tempList);
              offset = offset + perPage;
            }
          } else {
            isLoadingmore = false;
          }
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        }, onError: (error) {
          setSnackbar(error.toString(), context);
        },);
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, context);
        setState(() {
          _isLoading = false;
          isLoadingmore = false;
        });
      }
    } else {
      setState(() {
        _isNetworkAvail = false;
      });
    }
    return;
  }

  @override
  void dispose() {
    buttonController!.dispose();
    controller.dispose();
    amtC!.dispose();
    amtC1!.dispose();
    bankDetailC!.dispose();
    super.dispose();
  }

  Future<void> _refresh() {
    if (!isWithdraw) {
      setState(() {
        _isLoading = true;
      });
      offset = 0;
      total = 0;
      tranList.clear();
      return getTransaction();
    } else {
      setState(() {
        _isLoading = true;
      });
      offset1 = 0;
      total1 = 0;
      withdTranList.clear();
      return getWithdrawalTransaction();
    }
  }

  _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      if (mounted) {
        setState(() {
          isLoadingmore = true;
          if (!isWithdraw) {
            if (offset < total) getTransaction();
          } else {
            if (offset1 < total1) getWithdrawalTransaction();
          }
        });
      }
    }
  }

  Future<void> _getpaymentMethod() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        final parameter = {
          TYPE: PAYMENT_METHOD,
        };
        apiBaseHelper.postAPICall(getSettingApi, parameter).then(
            (getdata) async {
          final bool error = getdata["error"];
          if (!error) {
            final data = getdata["data"];
            final payment = data["payment_method"];
            print(
                "payment method*****$payment*****${payment['myfaoorah_payment_method']}",);
            paypal = payment["paypal_payment_method"] == "1" ? true : false;
            paumoney =
                payment["payumoney_payment_method"] == "1" ? true : false;
            flutterwave =
                payment["flutterwave_payment_method"] == "1" ? true : false;
           
            stripe = payment["stripe_payment_method"] == "1" ? true : false;
            paytm = payment["paytm_payment_method"] == "1" ? true : false;
            midTrans = payment['midtrans_payment_method'] == '1' ? true : false;
            myfatoorah =
                payment['myfaoorah_payment_method'] == '1' ? true : false;
            instamojo =
                payment['instamojo_payment_method'] == '1' ? true : false;
           
            if (midTrans!) {
              midTranshMerchandId = payment['midtrans_merchant_id'];
              midtransPaymentMethod = payment['midtrans_payment_method'];
              midtransPaymentMode = payment['midtrans_payment_mode'];
              midtransServerKey = payment['midtrans_server_key'];
              midtrashClientKey = payment['midtrans_client_key'];
            }
            if (myfatoorah!) {
              myfatoorahToken = payment['myfatoorah_token'];
              myfatoorahPaymentMode = payment['myfatoorah_payment_mode'];
              myfatoorahSuccessUrl = payment['myfatoorah__successUrl'];
              myfatoorahErrorUrl = payment['myfatoorah__errorUrl'];
              myfatoorahLanguage = payment['myfatoorah_language'];
              myfatoorahCountry = payment['myfatoorah_country'];
            }
            
            
            if (stripe!) {
              stripeId = payment['stripe_publishable_key'];
              stripeSecret = payment['stripe_secret_key'];
              stripeCurCode = payment['stripe_currency_code'];
              stripeMode = payment['stripe_mode'] ?? 'test';
              StripeService.secret = stripeSecret;
              StripeService.init(stripeId, stripeMode);
            }
            if (paytm!) {
              paytmMerId = payment['paytm_merchant_id'];
              paytmMerKey = payment['paytm_merchant_key'];
              payTesting =
                  payment['paytm_payment_mode'] == 'sandbox' ? true : false;
            }
            for (int i = 0; i < paymentMethodList.length; i++) {
              payModel.add(RadioModel(
                  isSelected: i == selectedMethod ? true : false,
                  name: paymentMethodList[i],
                  img: paymentIconList[i],),);
            }
          }
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
          if (dialogState != null) dialogState!(() {});
        }, onError: (error) {
          setSnackbar(error.toString(), context);
        },);
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, context);
      }
    } else {
      if (mounted) {
        setState(() {
          _isNetworkAvail = false;
        });
      }
    }
  }

  showContent() {
    return RefreshIndicator(
        color: Theme.of(context).colorScheme.primarytheme,
        key: _refreshIndicatorKey,
        onRefresh: _refresh,
        child: SingleChildScrollView(
          controller: controller,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.account_balance_wallet,
                            color: Theme.of(context).colorScheme.fontColor,
                          ),
                          Text(
                            " ${getTranslated(context, 'CURBAL_LBL')!}",
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.fontColor,
                                    fontWeight: FontWeight.bold,),
                          ),
                        ],
                      ),
                      Consumer<UserProvider>(
                          builder: (context, userProvider, _) {
                        return Text(
                            getPriceFormat(context,
                                double.parse(userProvider.curBalance),)!,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.fontColor,
                                    fontWeight: FontWeight.bold,),);
                      },),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SimBtn(
                              width: 0.39,
                              height: 35,
                              title: getTranslated(context, "ADD_MONEY"),
                              onBtnSelected: () {
                                _showDialog();
                              },
                            ),
                            SimBtn(
                              width: 0.39,
                              height: 35,
                              title: getTranslated(context, 'WIDTH_MON_LBL'),
                              onBtnSelected: () {
                                withDrawDailog();
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (!isWithdraw) tranList.isEmpty
                    ? getNoItem(context)
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                                getTranslated(context, 'WAL_TRANS_LBL')!,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .fontColor,
                                        fontWeight: FontWeight.bold,),),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: (offset < total)
                                ? tranList.length + 1
                                : tranList.length,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return (index == tranList.length && isLoadingmore)
                                  ? Center(
                                      child: CircularProgressIndicator(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primarytheme,
                                    ),)
                                  : listItem(index);
                            },
                          ),
                        ],
                      ) else withdTranList.isEmpty
                    ? getNoItem(context)
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                                getTranslated(context, 'WITHD_WAL_TRANS_LBL')!,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .fontColor,
                                        fontWeight: FontWeight.bold,),),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: (offset1 < total1)
                                ? withdTranList.length + 1
                                : withdTranList.length,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return (index == withdTranList.length &&
                                      isLoadingmore)
                                  ? Center(
                                      child: CircularProgressIndicator(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primarytheme,
                                    ),)
                                  : listItem1(index);
                            },
                          ),
                        ],
                      ),
          ],),
        ),);
  }
}
