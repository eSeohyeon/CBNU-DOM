import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled/themes/colors.dart';
import 'package:untitled/themes/styles.dart';
import 'package:lottie/lottie.dart';
import 'package:untitled/laundry/nfc_reader_page.dart';

class LaundryCardModal extends StatefulWidget {
  const LaundryCardModal({super.key});

  @override
  State<LaundryCardModal> createState() => _LaundryCardModalState();
}

class _LaundryCardModalState extends State<LaundryCardModal> {
  final NfcService _nfcService = NfcService();
  final ValueNotifier<String> _scanStatusNotifier = ValueNotifier('NFC 기능을 켜고, 세탁카드를 인식시켜 주세요.');
  int? _balance;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScan();
    });
  }

  void _startScan() {
    if (_isScanning) return;
    setState(() {
      _isScanning = true;
      _balance = null;
    });
    _scanStatusNotifier.value = '세탁카드 태그 대기 중...';

    _nfcService.startNfcScan(
        statusNotifier: _scanStatusNotifier,
        onBalanceRead: (balance) {
          if (mounted) {
            setState(() {
              _balance = balance;
              _isScanning = false;
            });
          }
        },
        onError: (errorMessage) {
          if (mounted) {
            _scanStatusNotifier.value = errorMessage;
            setState(() {
              _isScanning = false;
            });
          }
        },
        onScanFinished: () {
          if (mounted) {
            setState(() => _isScanning = false);
          }
        }
    );
  }


  @override
  void dispose() {
    _nfcService.stopNfcSession();
    _scanStatusNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: false,
        child: Container(
            height: 0.48.sh,
            decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
            ),
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          '세탁카드 잔액확인',
                          style: boldBlack18,
                          textAlign: TextAlign.start,
                        ),
                      ),
                      Expanded(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Lottie.asset('assets/lottie_nfc.json', width: 200.w, height: 200.h),
                                ValueListenableBuilder<String>(
                                  valueListenable: _scanStatusNotifier,
                                  builder: (context, message, _) {
                                    return _balance != null ? SizedBox.shrink() : Text(message, style: mediumGrey13, textAlign: TextAlign.center);
                                  },
                                ),
                                SizedBox(height: 10.h),
                                if (_balance != null)
                                  Text('잔액 : ${_balance}원', style: boldBlack20)
                                else if (_isScanning && _scanStatusNotifier.value.contains('읽는 중'))
                                  SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                              ]
                          )
                      ),
                      SizedBox(height: 10.h),
                      SizedBox(
                        width: double.infinity,
                        height: 48.h,
                        child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: black,
                                overlayColor: Colors.transparent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
                                elevation: 0
                            ),
                            child: Text('닫기', style: boldWhite15)
                        ),
                      ),
                    ]
                )
            )
        )
    );
  }
}