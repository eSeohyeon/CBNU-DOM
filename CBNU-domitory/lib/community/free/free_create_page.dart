import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:untitled/models/post.dart';
import 'package:untitled/themes/colors.dart';
import 'package:untitled/themes/styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled/common/custom_text_field.dart';

class CreateFreePost extends StatefulWidget {
  final Post? existingPost;
  const CreateFreePost({super.key, this.existingPost});

  @override
  State<CreateFreePost> createState() => _CreateFreePostState();
}

class _CreateFreePostState extends State<CreateFreePost> {
  final _titleController = TextEditingController();
  final _contentsController = TextEditingController();
  bool _isRegistering = false;
  bool get isEditMode => widget.existingPost != null;

  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedImages = [];
  final List<String> _existingImageUrls = [];

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      _titleController.text = widget.existingPost!.title;
      _contentsController.text = widget.existingPost!.contents;
      if (widget.existingPost!.imageUrls != null) {
        _existingImageUrls.addAll(widget.existingPost!.imageUrls!);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentsController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage();
      final totalImages =
          _selectedImages.length + _existingImageUrls.length + pickedFiles.length;
      if (totalImages > 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미지는 최대 5개까지 첨부할 수 있습니다.')),
        );
        return;
      }
      if (pickedFiles.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(pickedFiles);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미지를 가져오는 데 실패했습니다: $e')),
      );
    }
  }

  void _removeNewImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _removeExistingImage(int index) {
    setState(() {
      _existingImageUrls.removeAt(index);
    });
  }

  Future<void> _processPost() async {
    if (_titleController.text.isEmpty || _contentsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목과 내용을 모두 입력해주세요.')),
      );
      return;
    }

    setState(() => _isRegistering = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('로그인 정보가 없습니다. 다시 로그인해주세요.');
      }

      List<String> newImageUrls = [];
      for (final imageFile in _selectedImages) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('free_post_images')
            .child(
            '${user.uid}/${DateTime.now().millisecondsSinceEpoch}_${imageFile.name}');
        await ref.putFile(File(imageFile.path));
        final downloadUrl = await ref.getDownloadURL();
        newImageUrls.add(downloadUrl);
      }

      final allImageUrls = [..._existingImageUrls, ...newImageUrls];

      final postData = {
        'title': _titleController.text.trim(),
        'contents': _contentsController.text.trim(),
        'imageUrls': allImageUrls,
        'updatedAt': Timestamp.now(), // 수정 시간 기록
      };

      if (isEditMode) {
        // 기존 게시글 업데이트
        await FirebaseFirestore.instance
            .collection('free_posts')
            .doc(widget.existingPost!.postId)
            .update(postData);
      } else {
        // 새 게시글 생성
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        final nickname = userDoc.data()?['nickname'] ?? '이름 없음';
        final fullPostData = {
          ...postData,
          'authorUid': user.uid,
          'authorNickname': nickname,
          'createdAt': Timestamp.now(),
          'likes': [],
          'likeCount': 0,
        };
        await FirebaseFirestore.instance
            .collection('free_posts')
            .add(fullPostData);
      }

      if (mounted) {
        final message = isEditMode ? '게시글이 성공적으로 수정되었습니다.' : '게시글이 성공적으로 등록되었습니다.';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('게시글 처리에 실패했습니다: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRegistering = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: white,
        surfaceTintColor: white,
        title: Text(isEditMode ? '글 수정' : '글쓰기', style: mediumBlack16),
        leading: IconButton(
          icon: Icon(Icons.close, color: black, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isRegistering)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Center(
                  child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))),
            )
          else
            TextButton(
              onPressed: _processPost,
              child: Text(isEditMode ? '수정' : '등록', style: mediumBlack16),
            ),
        ],
        titleSpacing: 0,
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child:
            Column(mainAxisSize: MainAxisSize.min, children: [
              CustomTextField(
                  controller: _titleController,
                  name: '제목을 입력하세요.',
                  inputType: TextInputType.text,
                  maxLines: 1,
                  maxLength: 50),
              SizedBox(height: 10.h),
              TextField(
                controller: _contentsController,
                maxLines: 10,
                maxLength: 1000,
                style: mediumBlack16,
                decoration: InputDecoration(
                  hintText: '내용을 입력하세요.',
                  hintStyle: mediumGrey14,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: grey_seperating_line),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: grey_seperating_line),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: black),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              SizedBox(
                height: 100.h,
                child: Row(
                  children: [
                    InkWell(
                      onTap: _pickImages,
                      child: Container(
                        width: 100.w,
                        height: 100.h,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: grey_seperating_line),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, color: grey),
                            Text(
                                '${_selectedImages.length + _existingImageUrls.length}/5',
                                style: mediumGrey14),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedImages.length + _existingImageUrls.length,
                        itemBuilder: (context, index) {
                          Widget imageWidget;
                          VoidCallback onRemove;
                          if (index < _existingImageUrls.length) {
                            imageWidget = Image.network(
                              _existingImageUrls[index],
                              width: 100.w,
                              height: 100.h,
                              fit: BoxFit.cover,
                            );
                            onRemove = () => _removeExistingImage(index);
                          } else {
                            final fileIndex = index - _existingImageUrls.length;
                            imageWidget = Image.file(
                              File(_selectedImages[fileIndex].path),
                              width: 100.w,
                              height: 100.h,
                              fit: BoxFit.cover,
                            );
                            onRemove = () => _removeNewImage(fileIndex);
                          }

                          return Padding(
                            padding: EdgeInsets.only(right: 10.w),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: imageWidget,
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: InkWell(
                                    onTap: onRemove,
                                    child: CircleAvatar(
                                      radius: 12,
                                      backgroundColor:
                                      Colors.black.withOpacity(0.6),
                                      child: Icon(Icons.close,
                                          size: 16, color: white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

