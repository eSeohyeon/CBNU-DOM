import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled/common/custom_text_field.dart';
import 'package:untitled/themes/colors.dart';
import 'package:untitled/themes/styles.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:intl/intl.dart';

class GroupBuyCreatePage extends StatefulWidget {
  const GroupBuyCreatePage({super.key});

  @override
  State<GroupBuyCreatePage> createState() => _GroupBuyCreatePageState();
}

class _GroupBuyCreatePageState extends State<GroupBuyCreatePage> {
  final _productNameController = TextEditingController();
  final _productUrlController = TextEditingController();
  final _totalPriceController = TextEditingController();
  final _participantsController = TextEditingController();
  final _contentController = TextEditingController();

  bool _isSearchingPrice = false;
  String? _lowestPrice;
  String? _searchError;
  String? _productImageUrl;
  bool _isRegistering = false;

  // 최저가와 이미지를 검색하는 함수
  Future<void> _fetchLowestPrice() async {
    if (_productNameController.text.isEmpty) {
      setState(() {
        _searchError = '상품명을 먼저 입력해주세요.';
        _lowestPrice = null;
        _productImageUrl = null;
      });
      return;
    }

    setState(() {
      _isSearchingPrice = true;
      _lowestPrice = null;
      _searchError = null;
      _productImageUrl = null;
    });

    try {
      final productName = _productNameController.text;
      final url = Uri.parse('https://search.danawa.com/dsearch.php?query=${Uri.encodeComponent(productName)}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final document = parser.parse(response.body);

        final firstProduct = document.querySelector('.prod_item');
        if (firstProduct == null) {
          throw Exception('상품 정보를 찾을 수 없습니다. 다른 검색어로 시도해보세요.');
        }

        final priceElement = firstProduct.querySelector('.price_sect a strong');
        if (priceElement == null) throw Exception('가격을 찾을 수 없습니다.');
        final priceString = priceElement.text.replaceAll(RegExp(r'[^0-9]'), '');
        final price = int.tryParse(priceString);
        if (price == null) throw Exception('가격을 분석할 수 없습니다.');

        final imageElement = firstProduct.querySelector('.thumb_image img');
        String? imageUrl;
        if (imageElement != null) {
          imageUrl = imageElement.attributes['src'] ?? imageElement.attributes['data-original'];
          if (imageUrl != null && imageUrl.startsWith('//')) {
            imageUrl = 'https:$imageUrl';
          }
        }

        setState(() {
          _lowestPrice = '${NumberFormat('#,###').format(price)}원';
          _productImageUrl = imageUrl;
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

  // --- 게시글 등록 함수 ---
  Future<void> _registerPost() async {
    if (_productNameController.text.isEmpty ||
        _totalPriceController.text.isEmpty ||
        _participantsController.text.isEmpty ||
        _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('상품 링크를 제외한 모든 필드를 입력해주세요.')),
      );
      return;
    }

    setState(() => _isRegistering = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('로그인 정보가 없습니다. 다시 로그인해주세요.');
      }

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final nickname = userDoc.data()?['nickname'] ?? '이름 없음';

      await FirebaseFirestore.instance.collection('group_buy_posts').add({
        'productName': _productNameController.text.trim(),
        'productUrl': _productUrlController.text.trim(),
        'productImageUrl': _productImageUrl, // 불러온 이미지 주소 저장
        'totalPrice': int.tryParse(_totalPriceController.text.trim()) ?? 0,
        'maxParticipants': int.tryParse(_participantsController.text.trim()) ?? 1,
        'currentParticipants': 1,
        'content': _contentController.text.trim(),
        'authorUid': user.uid,
        'authorNickname': nickname,
        'createdAt': Timestamp.now(),
        'status': 'recruiting',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('게시글이 성공적으로 등록되었습니다.')),
      );

      Navigator.of(context).pop();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('게시글 등록에 실패했습니다: ${e.toString()}')),
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

  // --- 이미지 미리보기 UI를 위한 헬퍼 위젯 ---
  Widget _buildImagePreview() {
    if (_isSearchingPrice) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_productImageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          _productImageUrl!,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Icon(Icons.error_outline, color: Colors.red, size: 40),
            );
          },
        ),
      );
    }
    // 초기 상태 또는 이미지가 없을 때
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_library_outlined, color: Colors.grey[600], size: 40),
          SizedBox(height: 8.h),
          Text('검증 시 상품 이미지가\n여기에 표시됩니다.', style: TextStyle(color: Colors.grey[700]), textAlign: TextAlign.center,),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        title: Text('공동구매 글쓰기', style: mediumBlack16),
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
              child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
            )
          else
            TextButton(
              onPressed: _registerPost,
              child: Text('등록', style: mediumBlack16),
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
                        child: const CircularProgressIndicator(color: white, strokeWidth: 2),
                      )
                          : const Text('검증'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              Text('상품 이미지', style: mediumBlack16),
              SizedBox(height: 6.h),
              Center(
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

              Text('상품 링크 (선택)', style: mediumBlack16),
              SizedBox(height: 6.h),
              CustomTextField(
                controller: _productUrlController,
                name: '상품 판매 페이지 링크를 입력하세요',
                inputType: TextInputType.url,
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
