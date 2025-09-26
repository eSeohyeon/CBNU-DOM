import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:untitled/common/custom_text_field.dart';
import 'package:untitled/models/post.dart';
import 'package:untitled/themes/colors.dart';
import 'package:untitled/themes/styles.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:intl/intl.dart';

class GroupBuyCreatePage extends StatefulWidget {
  final GroupBuyPost? existingPost;
  const GroupBuyCreatePage({super.key, this.existingPost});

  @override
  State<GroupBuyCreatePage> createState() => _GroupBuyCreatePageState();
}

class _GroupBuyCreatePageState extends State<GroupBuyCreatePage> {
  final _productNameController = TextEditingController();
  final _productUrlController = TextEditingController();
  final _totalPriceController = TextEditingController();
  final _participantsController = TextEditingController();
  final _contentController = TextEditingController();

  bool get isEditMode => widget.existingPost != null;
  bool _isSearchingPrice = false;
  String? _lowestPrice;
  String? _searchError;
  bool _isRegistering = false;

  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  String? _existingImageUrl;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      final post = widget.existingPost!;
      _productNameController.text = post.basePost.title;
      _productUrlController.text = post.itemUrl;
      _totalPriceController.text = post.itemPrice.toString();
      _participantsController.text = post.maxParticipants.toString();
      _contentController.text = post.basePost.contents;
      _existingImageUrl = post.itemImagePath;
    }
  }

  Future<void> _fetchLowestPrice() async {
    if (_productNameController.text.isEmpty) {
      setState(() {
        _searchError = '상품명을 먼저 입력해주세요.';
        _lowestPrice = null;
      });
      return;
    }

    setState(() {
      _isSearchingPrice = true;
      _lowestPrice = null;
      _searchError = null;
    });

    try {
      final productName = _productNameController.text;
      final url = Uri.parse(
          'https://search.danawa.com/dsearch.php?query=${Uri.encodeComponent(productName)}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final document = parser.parse(response.body);
        final priceElement =
        document.querySelector('.price_sect a strong');
        if (priceElement == null) throw Exception('가격을 찾을 수 없습니다.');
        final priceString = priceElement.text.replaceAll(RegExp(r'[^0-9]'), '');
        final price = int.tryParse(priceString);
        if (price == null) throw Exception('가격을 분석할 수 없습니다.');

        setState(() {
          _lowestPrice = '${NumberFormat('#,###').format(price)}원';
        });
      } else {
        throw Exception('다나와 검색에 실패했습니다. (상태 코드: ${response.statusCode})');
      }
    } catch (e) {
      setState(() {
        _searchError = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isSearchingPrice = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile =
      await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = pickedFile;
          _existingImageUrl = null; // 새 이미지 선택 시 기존 이미지 URL 제거
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미지를 가져오는 데 실패했습니다: $e')),
      );
    }
  }

  Future<void> _processPost() async {
    if (_productNameController.text.isEmpty ||
        _productUrlController.text.isEmpty ||
        _totalPriceController.text.isEmpty ||
        _participantsController.text.isEmpty ||
        _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 필수 필드를 입력해주세요.')),
      );
      return;
    }
    if (_selectedImage == null && _existingImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('상품 이미지를 첨부해주세요.')),
      );
      return;
    }

    setState(() => _isRegistering = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('로그인 정보가 없습니다. 다시 로그인해주세요.');
      }

      String imageUrl;
      if (_selectedImage != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('group_buy_images')
            .child('${user.uid}/${DateTime.now().millisecondsSinceEpoch}');
        await ref.putFile(File(_selectedImage!.path));
        imageUrl = await ref.getDownloadURL();
      } else {
        imageUrl = _existingImageUrl!;
      }

      final postData = {
        'productName': _productNameController.text.trim(),
        'productUrl': _productUrlController.text.trim(),
        'productImageUrl': imageUrl,
        'totalPrice': int.tryParse(_totalPriceController.text.trim()) ?? 0,
        'maxParticipants':
        int.tryParse(_participantsController.text.trim()) ?? 1,
        'content': _contentController.text.trim(),
        'updatedAt': Timestamp.now(),
      };

      if (isEditMode) {
        // 기존 게시글 업데이트
        await FirebaseFirestore.instance
            .collection('group_buy_posts')
            .doc(widget.existingPost!.basePost.postId)
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
          'currentParticipants': 1,
          'authorUid': user.uid,
          'authorNickname': nickname,
          'createdAt': Timestamp.now(),
          'status': 'recruiting',
          'likes': [],
          'likeCount': 0,
        };
        await FirebaseFirestore.instance
            .collection('group_buy_posts')
            .add(fullPostData);
      }

      if (mounted) {
        final message = isEditMode ? '게시글이 성공적으로 수정되었습니다.' : '게시글이 성공적으로 등록되었습니다.';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
        Navigator.of(context).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('게시글 처리에 실패했습니다: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isRegistering = false);
      }
    }
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _productUrlController.dispose();
    _totalPriceController.dispose();
    _participantsController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Widget _buildImagePreview() {
    if (_selectedImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(
          File(_selectedImage!.path),
          fit: BoxFit.contain,
        ),
      );
    }
    if (_existingImageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          _existingImageUrl!,
          fit: BoxFit.contain,
        ),
      );
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_library_outlined, color: Colors.grey[600], size: 40),
          SizedBox(height: 8.h),
          Text('이미지를 첨부해주세요.',
              style: TextStyle(color: Colors.grey[700]),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        title: Text(isEditMode ? '공동구매 수정' : '공동구매 글쓰기', style: mediumBlack16),
        backgroundColor: white,
        surfaceTintColor: white,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: black, size: 24),
          onPressed: () {
            Navigator.pop(context);
          },
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
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('상품명', style: mediumBlack16),
              SizedBox(height: 6.h),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _productNameController,
                      name: '상품명을 입력하세요',
                      inputType: TextInputType.text,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  SizedBox(
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed: _isSearchingPrice ? null : _fetchLowestPrice,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: black,
                        foregroundColor: white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isSearchingPrice
                          ? SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: const CircularProgressIndicator(
                            color: white, strokeWidth: 2),
                      )
                          : const Text('검증'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              if (_lowestPrice != null)
                Text(
                  '다나와 최저가: $_lowestPrice',
                  style: mediumBlack14,
                ),
              if (_searchError != null)
                Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Text(
                    _searchError!,
                    style: mediumBlack14.copyWith(color: Colors.red),
                  ),
                ),
              SizedBox(height: 24.h),
              Text('상품 이미지', style: mediumBlack16),
              SizedBox(height: 6.h),
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 250.h,
                    width: MediaQuery.of(context).size.width * 0.6,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: _buildImagePreview(),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Text('상품 링크', style: mediumBlack16),
              SizedBox(height: 6.h),
              CustomTextField(
                controller: _productUrlController,
                name: '상품 판매 페이지 링크를 입력하세요',
                inputType: TextInputType.url,
                maxLength: 255, // 글자수 제한 없음
              ),
              SizedBox(height: 24.h),
              Text('총 금액', style: mediumBlack16),
              SizedBox(height: 6.h),
              CustomTextField(
                controller: _totalPriceController,
                name: '배송비 포함 총 금액을 입력하세요',
                inputType: TextInputType.number,
              ),
              SizedBox(height: 24.h),
              Text('모집 인원', style: mediumBlack16),
              SizedBox(height: 6.h),
              CustomTextField(
                controller: _participantsController,
                name: '본인을 포함한 총 모집 인원을 입력하세요',
                inputType: TextInputType.number,
              ),
              SizedBox(height: 24.h),
              Text('내용', style: mediumBlack16),
              SizedBox(height: 6.h),
              TextField(
                controller: _contentController,
                maxLines: 8,
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
              SizedBox(height: 28.h)
            ],
          ),
        ),
      ),
    );
  }
}

