/*
 * Copyright (C) 2020. by perol_notsf, All rights reserved
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/network/oauth_client.dart';
import 'package:pixez/network/onezero_client.dart';
import 'package:pixez/page/hello/android_hello_page.dart';
import 'package:pixez/page/hello/hello_page.dart';
import 'package:pixez/page/splash/splash_store.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  SplashStore splashStore;
  @override
  void initState() {
    splashStore = SplashStore(OnezeroClient())..fetch();
    controller =
        AnimationController(duration: Duration(seconds: 2), vsync: this);
    initMethod();
    super.initState();
    controller.forward();
  }

  ReactionDisposer reactionDisposer;
  initMethod() {
    reactionDisposer = reaction((_) => splashStore.helloWord, (_) {
      try {
        if (splashStore.onezeroResponse != null) {
          var address = splashStore.onezeroResponse.answer.first.data;
          print('address:$address');
          if (address != null && address.isNotEmpty) {
             RepositoryProvider.of<ApiClient>(context)
                .httpClient
                .options
                .baseUrl = 'https://$address';
            RepositoryProvider.of<OAuthClient>(context)
                .httpClient
                .options
                .baseUrl = 'https://$address';
          }
        }
      } catch (e) {
        print(e);
      }
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) =>
                  Platform.isIOS ? HelloPage() : AndroidHelloPage()));
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    reactionDisposer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    saveStore.initContext(I18n.of(context));
    return Observer(builder: (_) {
      return Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            RotationTransition(
                child: Image.asset(
                  'assets/images/icon.png',
                  height: 80,
                  width: 80,
                ),
                alignment: Alignment.center,
                turns: controller),
            Container(
              child: Text(
                splashStore.helloWord,
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      );
    });
  }
}
