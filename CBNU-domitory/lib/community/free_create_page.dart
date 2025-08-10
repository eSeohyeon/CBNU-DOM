import 'package:flutter/material.dart';
import 'package:untitled/themes/colors.dart';
import 'package:untitled/themes/styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled/models/post.dart';
import 'package:untitled/common/custom_text_field.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CreateFreePost extends StatefulWidget {
  const CreateFreePost({super.key});

  @override
  State<CreateFreePost> createState() => _CreateFreePostState();
}

class _CreateFreePostState extends State<CreateFreePost> {
  final _titleController = TextEditingController();
  final _contentsController = TextEditingController();
  int _currentTitleLength=0;
  int _currentContentsLength=0;

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
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentsController.dispose();
    super.dispose();
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
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("제목", style: mediumBlack16),
              SizedBox(height: 10.h),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(controller: _titleController, name: '제목을 입력하세요.', inputType: TextInputType.visiblePassword, maxLines: 1, maxLength: 32),
                  SizedBox(height: 8.h),
                  Text('$_currentTitleLength/32', style: mediumGrey14)
                ]
              ),
              SizedBox(height: 32.h),
              Text("내용", style: mediumBlack16),
              SizedBox(height: 10.h),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 300.h, child: CustomTextField(controller: _contentsController, name: '내용을 입력하세요.', inputType: TextInputType.visiblePassword, maxLines: 30, maxLength: 600)),
                  SizedBox(height: 8.h),
                  Text('$_currentContentsLength/600', style: mediumGrey14)
                ]
              )
            ]
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
          child: SizedBox(
            width: double.infinity,
            height: 45.h,
            child: ElevatedButton(
              child: Text("글 올리기", style: mediumWhite16),
              onPressed: () {
                if(_currentTitleLength==0 && _currentContentsLength==0){
                  showToast("제목과 내용을 입력해주세요.");
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


