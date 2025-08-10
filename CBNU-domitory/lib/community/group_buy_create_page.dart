import 'package:flutter/material.dart';
import 'package:untitled/themes/colors.dart';
import 'package:untitled/themes/styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled/models/post.dart';
import 'package:untitled/common/custom_text_field.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';

class GroupBuyCreatePage extends StatefulWidget {
  const GroupBuyCreatePage({super.key});

  @override
  State<GroupBuyCreatePage> createState() => _GroupBuyCreatePageState();
}

class _GroupBuyCreatePageState extends State<GroupBuyCreatePage> {
  final _titleController = TextEditingController();
  final _contentsController = TextEditingController();
  final _itemUrlController = TextEditingController();
  final _itemPriceController = TextEditingController();
  final _maxParticipantsController = TextEditingController();
  int _currentTitleLength=0;
  int _currentContentsLength=0;
  int _currentURLLength=0;
  int _currentPriceLength=0;
  int _currentParticipantsLength=0;
  int _perPersonPrice=0;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(() {
      setState(() {
        _currentTitleLength = _titleController.text.length;
      });
    });
    _contentsController.addListener(() {
      setState(() {
        _currentContentsLength = _contentsController.text.length;
      });
    });
    _itemUrlController.addListener(() {
      setState(() {
        _currentURLLength = _itemUrlController.text.length;
      });
    });
    _itemPriceController.addListener(() {
      setState(() {
        _currentPriceLength = _itemPriceController.text.length;
        _updatePerPersonPrice();
      });
    });
    _maxParticipantsController.addListener(() {
      setState(() {
        _currentParticipantsLength = _maxParticipantsController.text.length;
        _updatePerPersonPrice();
      });
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentsController.dispose();
    _itemUrlController.dispose();
    _itemPriceController.dispose();
    _maxParticipantsController.dispose();
    super.dispose();
  }

  void _updatePerPersonPrice(){
    final price = int.tryParse(_itemPriceController.text) ?? 0;
    final participants = int.tryParse(_maxParticipantsController.text) ?? 0;

    if(participants > 0){
      _perPersonPrice = (price/participants).floor();
    } else {
      _perPersonPrice = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: white,
        surfaceTintColor: white,
        title: Text('글쓰기', style: mediumBlack18),
        leading: IconButton(
          icon: Icon(Icons.close, color: black, size: 24),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        titleSpacing: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("상품명", style: mediumBlack16),
              SizedBox(height: 10.h),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextField(controller: _titleController, name: '상품명을 입력하세요.', inputType: TextInputType.visiblePassword, maxLines: 1, maxLength: 32),
                    SizedBox(height: 8.h),
                    Text('$_currentTitleLength/32', style: mediumGrey14)
                  ]
              ),
              SizedBox(height: 20.h),
              Text("상품URL", style: mediumBlack16),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Expanded(
                  child: CustomTextField(controller: _itemUrlController, name: '상품URL을 입력하세요.', inputType: TextInputType.visiblePassword, maxLines: 1, maxLength: 300),
              ),
                  SizedBox(width: 8.w),
                  Container(
                    width: 46.w,
                    height: 46.h,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), color: grey_button),
                    child: IconButton(
                      icon: Icon(Icons.content_paste_rounded, color: grey, size: 28),
                      onPressed: () async {
                        final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);

                        if(clipboardData != null && clipboardData.text !=null) {
                          setState(() {
                            _itemUrlController.text = clipboardData.text!;
                          });
                        }
                      }
                    )
                    )
                ]
              ),
              SizedBox(height: 20.h),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("가격", style: mediumBlack16),
                    SizedBox(height: 10.h),
                    SizedBox(
                      width: 150.w,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomTextField(controller: _itemPriceController, name: '가격을 입력하세요.', inputType: TextInputType.visiblePassword, maxLines: 1, maxLength: 10, suffix: '원'),
                            SizedBox(height: 4.h),
                            Text('1인당 ${_perPersonPrice}원', style: mediumGrey13)
                          ]
                      ),
                    )
                  ]
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: 120.w,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("인원수", style: mediumBlack16),
                      SizedBox(height: 10.h),
                      CustomTextField(controller: _maxParticipantsController, name: '인원수를 입력하세요.', inputType: TextInputType.visiblePassword, maxLines: 1, maxLength: 2, suffix: '명')
                    ]
                ),
              ),
              SizedBox(height: 20.h),
              Text("내용", style: mediumBlack16),
              SizedBox(height: 10.h),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 100.h, child: CustomTextField(controller: _contentsController, name: '내용을 입력하세요.', inputType: TextInputType.visiblePassword, maxLines: 20, maxLength: 300)),
                    SizedBox(height: 8.h),
                    Text('$_currentContentsLength/300', style: mediumGrey14)
                  ]
              )
            ]
          )
        )
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 24.w),
            child: SizedBox(
              width: double.infinity,
              height: 45.h,
              child: ElevatedButton(
                child: Text("글 올리기", style: mediumWhite16),
                onPressed: () {
                  if(_currentTitleLength==0 && _currentContentsLength==0){
                    showToast("빈 칸 없이 입력해주세요.");
                  } else {
                    print("글 작성 완료!");
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: (_currentTitleLength==0)&&(_currentContentsLength==0) ? black40 : black, padding: EdgeInsets.only(top: 6.h, bottom: 6.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)), elevation: 2,),
              ),
            )
        ),
      )
    );
  }
}

void showToast(String message){
  Fluttertoast.showToast(
      msg: message,
      backgroundColor: Colors.grey,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      textColor: Colors.white,
      fontSize: 14,
      fontAsset: 'fonts/Pretendard-Medium.otf'
  );
}

