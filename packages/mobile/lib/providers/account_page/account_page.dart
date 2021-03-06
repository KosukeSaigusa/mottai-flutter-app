import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../services/auth_service.dart';
import '../../services/scaffold_messenger_service.dart';
import '../../utils/enums.dart';
import '../../utils/extensions/build_context.dart';
import '../overlay_loading/overlay_loading.dart';
import 'account_page_state.dart';

final accountPageController = StateNotifierProvider<AccountPageController, AccountPageState>(
  (ref) => AccountPageController(ref.read),
);

/// アカウントページのビューコントローラ。
/// 認証関係の処理については、AuthService とだけやり取りをして、
/// AuthRepository とは直接やり取りをしない。
class AccountPageController extends StateNotifier<AccountPageState> {
  AccountPageController(this._read) : super(const AccountPageState());

  final Reader _read;

  /// メールアドレスとパスワードでサインインする
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _read(overlayLoadingProvider.notifier).update((s) => true);
    try {
      await _read(authService).signInWithEmailAndPassword(email: email, password: password);
      _read(scaffoldMessengerServiceProvider).showSnackBar('サインインしました。');
    } on PlatformException catch (e) {
      _read(scaffoldMessengerServiceProvider).showSnackBar('[${e.code}] キャンセルしました。');
    } on FirebaseException catch (e) {
      _read(scaffoldMessengerServiceProvider).showSnackBarByFirebaseException(e);
    } on Exception {
      _read(scaffoldMessengerServiceProvider).showSnackBar('サインインに失敗しました。');
    } finally {
      _read(overlayLoadingProvider.notifier).update((s) => false);
    }
  }

  /// Google, Apple, or LINE でサインインする
  Future<void> signInWithSocialAccount(SocialSignInMethod method) async {
    if (method == SocialSignInMethod.LINE) {
      final agreed = await _agreeWithLINEEmailHandling;
      if (!agreed) {
        return;
      }
    }
    _read(overlayLoadingProvider.notifier).update((s) => true);
    try {
      await _read(authService).signInWithSocialAccount(method);
      _read(scaffoldMessengerServiceProvider).showSnackBar('サインインしました。');
    } on PlatformException catch (e) {
      _read(scaffoldMessengerServiceProvider)
          .showSnackBar('[${e.code}] サインインに失敗しました。(${e.toString()})');
    } on FirebaseException catch (e) {
      _read(scaffoldMessengerServiceProvider).showSnackBarByFirebaseException(e);
    } on Exception {
      _read(scaffoldMessengerServiceProvider).showSnackBar('サインインに失敗しました。');
    } finally {
      _read(overlayLoadingProvider.notifier).update((s) => false);
    }
  }

  /// LINE のログインの前にメールアドレスの取り扱いに
  /// 同意するかどうか確認するためのダイアログを表示する
  Future<bool> get _agreeWithLINEEmailHandling async {
    final agreed = await showDialog<bool>(
      context: _read(scaffoldMessengerServiceProvider).scaffoldMessengerKey.currentContext!,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: <Widget>[
              const FaIcon(FontAwesomeIcons.line, color: Color(0xff00ba52)),
              const Gap(8),
              Text('LINE ログインについて', style: context.titleSmall),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'このアプリでは、ログイン時の確認画面で許可を頂いた場合のみ、'
                'あなたの LINE アカウントに登録されているメールアドレスを取得します。'
                '取得したメールアドレスは、ユーザー管理および、他のソーシャルログインと'
                '連携する目的以外では使用しません。'
                'また、法令に定められた場合を除き、第三者へ提供することはありません。',
                style: context.bodySmall,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop<bool>(context, true),
              child: const Text('同意して進む'),
            ),
          ],
        );
      },
    );
    return agreed ?? false;
  }

  /// サインアウトする。
  Future<void> signOut() async {
    try {
      await _read(authService).signOut();
    } on FirebaseAuthException catch (e) {
      _read(scaffoldMessengerServiceProvider).showSnackBarByException(e);
    } on Exception {
      _read(scaffoldMessengerServiceProvider).showSnackBar('サインアウトに失敗しました。');
    }
  }
}
