import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:encrypt/encrypt.dart';

class DataEncryption {
  //static var ivString = "fbZUQijJVqIPfjtK";

  // generates random string len 16
  /*static String getRandString(int len) {
    const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz';
    Random _rnd = Random();

    return String.fromCharCodes(Iterable.generate(
        len, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  }*/

  static String encodeKeyWith(String key) {
    print(key);
    for (int i = 0; i < 32; i++) {
      if (i > 7 && i < 16) {
        var asciiCode = key.codeUnitAt(i);

        if (asciiCode < 68) {
          asciiCode += 23;
        } else if (asciiCode < 100 && asciiCode > 96) {
          asciiCode += 23;
        } else {
          asciiCode -= 3;
        }
        key = replaceCharAt(key, i, String.fromCharCode(asciiCode));
      } else if (i > 23 && i < 32) {
        var asciiCode = key.codeUnitAt(i);

        if (asciiCode < 68) {
          asciiCode += 23;
        } else if (asciiCode < 100 && asciiCode > 96) {
          asciiCode += 23;
        } else {
          asciiCode -= 3;
        }
        key = replaceCharAt(key, i, String.fromCharCode(asciiCode));
      } else {
        continue;
      }
    }

    return key;
  }

  static String replaceCharAt(String oldString, int index, String newChar) {
    return oldString.substring(0, index) +
        newChar +
        oldString.substring(index + 1);
  }

  // generates random string  len 32
  static String generateKey() {
    const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz';
    Random _rnd = Random();

    return String.fromCharCodes(Iterable.generate(
        32, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  }

  //encode generated key
  static String encodeKey(String str, int k) {
    var encodedString = "";
    var encodedString2 = "";
    var nothingencoded = "";
    var nothingencoded2 = "";

    for (int i = 0; i < 8; i++) {
      // var char = str[i];
      var charCode = str.codeUnitAt(i);
      var newChar2 = String.fromCharCode(charCode);
      nothingencoded += newChar2;
    }

    for (int i = 8; i < 16; i++) {
      // var char = str[i];
      var charCode = str.codeUnitAt(i);
      var newCharCode = charCode + k;
      var newChar = String.fromCharCode(newCharCode);

      //if k-th character exceeds 'Z'
      if (newCharCode > 122) {
        var newCharCode2 = newCharCode + 26;
        var newChar2 = String.fromCharCode(newCharCode2);
        encodedString += newChar2;
      }
      //if k-th character exceeds 'Z'
      else if (newCharCode > 90 && newCharCode < 97) {
        var newCharCode2 = newCharCode + 26;
        var newChar2 = String.fromCharCode(newCharCode2);
        encodedString += newChar2;
      } else if (newCharCode < 65) {
        var newCharCode2 = newCharCode + 26;
        var newChar2 = String.fromCharCode(newCharCode2);
        encodedString += newChar2;
      } else {
        encodedString += newChar;
      }
    }

    for (int i = 16; i < 24; i++) {
      // var char = str[i];
      var charCode = str.codeUnitAt(i);
      var newChar2 = String.fromCharCode(charCode);
      nothingencoded2 += newChar2;
    }

    for (int i = 24; i < str.length; i++) {
      // val char = str[i];
      var charCode = str.codeUnitAt(i);
      var newCharCode = charCode + k;
      var newChar = String.fromCharCode(newCharCode);

      //if k-th character exceeds 'Z'
      if (newCharCode > 122) {
        var newCharCode2 = newCharCode + 26;
        var newChar2 = String.fromCharCode(newCharCode2);
        encodedString2 += newChar2;
      }
      //if k-th character exceeds 'Z'
      else if (newCharCode > 90 && newCharCode < 97) {
        var newCharCode2 = newCharCode + 26;
        var newChar2 = String.fromCharCode(newCharCode2);
        encodedString2 += newChar2;
      } else if (newCharCode < 65) {
        var newCharCode2 = newCharCode + 26;
        var newChar2 = String.fromCharCode(newCharCode2);
        encodedString2 += newChar2;
      } else {
        encodedString2 += newChar;
      }
    }

    print(
        "converted key: ${nothingencoded + encodedString + nothingencoded2 + encodedString2}");
    return nothingencoded + encodedString + nothingencoded2 + encodedString2;
  }

  //Encrypt source data
  static String encryptWithAES(String strToEncrypt, String secret_key) {
    // final ivString = getRandString(16);
    // print('iv : $ivString');
    // var ivBtyes = Uint8List.fromList([1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]);
    // final iv = encrypt.IV(ivBtyes);

    final encrypter = Encrypter(
        AES(Key.fromUtf8(secret_key), mode: AESMode.ecb, padding: "PKCS7"));

    final encrypted = encrypter.encrypt(strToEncrypt, iv: IV.fromUtf8(""));

    print('encryptedData ${encrypted.base64}');

    return encrypted.base64;
  }

  //decode generated key
  static String decodeKey(String str, int k) {
    var encodedString = "";
    var encodedString2 = "";
    var nothingencoded = "";
    var nothingencoded2 = "";

    for (int i = 0; i < 8; i++) {
      // val char = str[i]
      var charCode = str.codeUnitAt(i);
      var newChar2 = String.fromCharCode(charCode);
      nothingencoded += newChar2;
    }

    for (int i = 8; i < 16; i++) {
      // val char = str[i]
      var charCode = str.codeUnitAt(i);
      var newCharCode = charCode + k;
      var newChar = String.fromCharCode(newCharCode);

      //if k-th character exceeds 'Z'
      if (newCharCode > 122) {
        var newCharCode2 = newCharCode + 26;
        var newChar2 = String.fromCharCode(newCharCode2);
        encodedString += newChar2;
      }
      //if k-th character exceeds 'Z'
      else if (newCharCode > 90 && newCharCode < 97) {
        var newCharCode2 = newCharCode + 26;
        var newChar2 = String.fromCharCode(newCharCode2);
        encodedString += newChar2;
      } else if (newCharCode < 65) {
        var newCharCode2 = newCharCode + 26;
        var newChar2 = String.fromCharCode(newCharCode2);
        encodedString += newChar2;
      } else {
        encodedString += newChar;
      }
    }

    for (int i = 16; i < 24; i++) {
      // val char = str[i]
      var charCode = str.codeUnitAt(i);
      var newChar2 = String.fromCharCode(charCode);
      nothingencoded2 += newChar2;
    }

    for (int i = 24; i < str.length; i++) {
      // val char = str[i]
      var charCode = str.codeUnitAt(i);
      var newCharCode = charCode + k;
      var newChar = String.fromCharCode(newCharCode);

      //if k-th character exceeds 'Z'
      if (newCharCode > 122) {
        var newCharCode2 = newCharCode + 26;
        var newChar2 = String.fromCharCode(newCharCode2);
        encodedString2 += newChar2;
      }
      //if k-th character exceeds 'Z'
      else if (newCharCode > 90 && newCharCode < 97) {
        var newCharCode2 = newCharCode + 26;
        var newChar2 = String.fromCharCode(newCharCode2);
        encodedString2 += newChar2;
      } else if (newCharCode < 65) {
        var newCharCode2 = newCharCode + 26;
        var newChar2 = String.fromCharCode(newCharCode2);
        encodedString2 += newChar2;
      } else {
        encodedString2 += newChar;
      }
    }
    print(
        "decodedkey: ${nothingencoded + encodedString + nothingencoded2 + encodedString2}");
    return nothingencoded + encodedString + nothingencoded2 + encodedString2;
  }

  //Decrypt received data
  static String? decryptWithAES(String key, String? strToDecrypt) {
    // var iv = getRandString(16);
    if (key != null) {
      print('strToDecrypt: $strToDecrypt');
      final decodedKey = decodeKey(key, -3);

      print('encodedKey: $decodedKey');

      // final endcodedIV = encodeIV(iv);
      // var ivBtyes = Uint8List.fromList([1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]);
      // final iv = encrypt.IV(ivBtyes);

      final encrypter = encrypt.Encrypter(
          AES(Key.fromUtf8(decodedKey), mode: AESMode.ecb, padding: "PKCS7"));

      final decrypted = encrypter.decrypt(Encrypted.fromBase64(strToDecrypt!),
          iv: IV.fromUtf8(""));

      print("Decrypted Data: " + decrypted.toString());

      return decrypted;
    } else {
      return strToDecrypt;
    }
  }

  static Map<String, dynamic> getEncryptedData(
      Map<String, dynamic> jsonObject) {
    var generateKey = DataEncryption.generateKey().toString();

    print('original $generateKey');

    var encodedReqKey = DataEncryption.encodeKey(generateKey, -3).toString();

    var encryptedData =
        DataEncryption.encryptWithAES(json.encode(jsonObject), generateKey);

    Map<String, dynamic> encryptedJsonObject = {
      // "env_type": "production",
      "reqData": encryptedData,
      "reqKey": encodedReqKey
    };

    print("encryptedJsonObject: $encryptedJsonObject");

    return encryptedJsonObject;
  }

  static Map<String, dynamic>  getDecryptedData(String resKey, String resData) {
    // var decodeKey = DataEncryption.decodeKey(resKey, -3);

    //decrypt data
    var decryptData = DataEncryption.decryptWithAES(resKey, resData);

    print("ResData : $resData");
    print("ResKey : $resKey");
    print("type : ${jsonDecode(decryptData!).runtimeType}");

    Map<String, dynamic> map = jsonDecode(decryptData);

    return map;
  }

}
