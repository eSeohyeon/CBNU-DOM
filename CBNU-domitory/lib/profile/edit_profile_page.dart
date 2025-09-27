// lib/profile/edit_profile_page.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled/themes/colors.dart';
import 'package:untitled/themes/styles.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nicknameController = TextEditingController();
  final _birthYearController = TextEditingController();
  final _enrollYearController = TextEditingController();
  final _departmentController = TextEditingController();

  bool _isLoading = true;
  String? _initialNickname;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  // Firestore에서 현재 사용자 데이터 불러오기
  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        _nicknameController.text = data['nickname'] ?? '';
        _birthYearController.text = data['birthYear'] ?? '';
        _enrollYearController.text = data['enrollYear'] ?? '';
        _departmentController.text = data['department'] ?? '';

        _initialNickname = null;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('정보를 불러오는 중 오류가 발생했습니다: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 변경된 정보를 Firestore에 저장하기
  Future<void> _saveUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'nickname': _nicknameController.text.trim(),
        'birthYear': _birthYearController.text.trim(),
        'enrollYear': _enrollYearController.text.trim(),
        'department': _departmentController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('정보가 성공적으로 수정되었습니다.')),
      );
      Navigator.of(context).pop(); // 저장 후 이전 화면으로 돌아가기

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('정보 저장 중 오류가 발생했습니다: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _birthYearController.dispose();
    _enrollYearController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: Text('정보 수정', style: mediumBlack16),
        backgroundColor: background,
        surfaceTintColor: background,
        titleSpacing: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('닉네임', style: mediumBlack16),
            SizedBox(height: 6.h),
            TextField(
              controller: _nicknameController,
              decoration: InputDecoration(border: OutlineInputBorder(), hintText: _initialNickname ?? '닉네임'),
            ),
            SizedBox(height: 20.h),

            Text('생년', style: mediumBlack16),
            SizedBox(height: 6.h),
            TextField(
              controller: _birthYearController,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: '생년'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20.h),

            Text('학번', style: mediumBlack16),
            SizedBox(height: 6.h),
            TextField(
              controller: _enrollYearController,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: '학번'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20.h),

            Text('학과', style: mediumBlack16),
            SizedBox(height: 6.h),
            TextField(
              controller: _departmentController,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: '학과'),
            ),
            SizedBox(height: 40.h),

            SizedBox(
              width: double.infinity,
              height: 45.h,
              child: ElevatedButton(
                onPressed: _saveUserData,
                style: btnBlackRound30,
                child: Text('저장하기', style: mediumWhite16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}