// lib/laundry/nfc_service.dart (새 파일)

import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart'; // ValueNotifier 사용 위해 추가
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';

class NfcService {
  // NFC 스캔 시작 함수
  Future<void> startNfcScan({
    required ValueNotifier<String> statusNotifier, // 스캔 상태 업데이트용 Notifier
    required Function(int) onBalanceRead,         // 잔액 읽기 성공 시 호출될 콜백
    required Function(String) onError,            // 오류 발생 시 호출될 콜백
    required Function() onScanFinished,           // 스캔 종료 시 호출될 콜백
  }) async {
    // NFC 지원 여부 확인 (선택 사항이지만 추가하면 좋음)
    bool isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable) {
      onError("NFC를 사용할 수 없는 기기입니다.");
      onScanFinished();
      return;
    }

    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        try {
          final mifare = MifareClassic.from(tag);
          if (mifare == null) {
            await NfcManager.instance.stopSession(errorMessage: 'Mifare Classic 카드가 아닙니다.');
            onError('오류: Mifare Classic 카드가 아닙니다.');
            return;
          }

          statusNotifier.value = '세탁 카드를 읽는 중입니다...\n(카드를 떼지 말고 유지해주세요)';

          int balance = await _readBalanceFromSector3(mifare);
          onBalanceRead(balance); // 콜백 함수 호출하여 잔액 전달
          statusNotifier.value = '✅ 스캔 성공!'; // 성공 메시지 설정

          await NfcManager.instance.stopSession();

        } catch (e) {
          await NfcManager.instance.stopSession(errorMessage: "오류 발생: $e");
          onError("❌ 스캔 오류:\n잔액 정보를 읽지 못했습니다.\n다시 시도해주세요.\n(상세: $e)");
        } finally {
          onScanFinished(); // 성공/실패 여부와 관계없이 스캔 종료 알림
        }
      },
      pollingOptions: { NfcPollingOption.iso14443 },
    ).catchError((e) {
      onError("NFC 세션 시작 중 오류 발생: $e");
      onScanFinished(); // 세션 시작 실패 시에도 스캔 종료 알림
    });
  }

  // NFC 세션 중지 함수
  Future<void> stopNfcSession() async {
    try {
      if (await NfcManager.instance.isAvailable()) {
        await NfcManager.instance.stopSession();
      }
    } catch (e) {
      print("NFC 세션 중지 중 오류 발생 (무시 가능): $e");
    }
  }


  // Sector 3 잔액 읽기 로직 (이전과 동일)
  Future<int> _readBalanceFromSector3(MifareClassic mifare) async {
    final List<Uint8List> keysToTry = [
      hexToBytes("FFFFFFFFFFFF"),
      hexToBytes("000000000000"),
      hexToBytes("A0A1A2A3A4A5"),
    ];

    const int sectorIndex = 3;
    const int blockIndexToRead = 13;

    for (final key in keysToTry) {
      try {
        await mifare.authenticateSectorWithKeyA(sectorIndex: sectorIndex, key: key);
        final data = await mifare.readBlock(blockIndex: blockIndexToRead);
        int balanceValue = (data[3] << 8) | data[2];
        return balanceValue * 1000;
      } catch (e) { /* Key A 실패 */ }

      try {
        await mifare.authenticateSectorWithKeyB(sectorIndex: sectorIndex, key: key);
        final data = await mifare.readBlock(blockIndex: blockIndexToRead);
        int balanceValue = (data[3] << 8) | data[2];
        return balanceValue * 1000;
      } catch (e) { /* Key B 실패 */ }
    }
    throw Exception('Sector 3 인증 실패');
  }

  // Helper 함수들 (이전과 동일)
  String bytesToHexString(Uint8List bytes) {
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join('').toUpperCase();
  }

  Uint8List hexToBytes(String hex) {
    return Uint8List.fromList(List.generate(hex.length ~/ 2, (i) => int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16)));
  }
}