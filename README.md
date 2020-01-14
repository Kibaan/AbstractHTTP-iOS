# AbstractHTTP

AbstractHTTP はHTTP通信とそれに付随する一連の処理を抽象化したライブラリです。

本ライブラリは大部分がプロトコルで構成されており、**通信の実装ではなく通信周りの設計を提供するものです**。


```
AbstractHTTP is abstract HTTP processing library.  
```

# プログラミングガイド (Programming guide)

## 基本の使い方 (Basic usages)

通信を行うためには `ConnectionSpec` プロトコル（またはRequestSpecとResponseSpecプロトコル）を実装したクラス（以下Specクラス）を作る必要があります。  
Specクラスは１つのAPIの仕様を表し、URLやパラメーターなどリクエストの詳細と、レスポンスのバリデーションとパース処理を記載します。  
REST APIであればURLとHTTPメソッドの組み合わせに対して１つSpecクラスを作成するのがおすすめです。

```swift
// シンプルなConnectionSpec実装
class SimplestSpec: ConnectionSpec {
    // 通信で受取るデータの型を定義する
    typealias ResponseModel = String

    // リクエスト先のURL 
    var url: String { return "https://www.google.com/" }
    
    // リクエストのHTTPメソッド
    var httpMethod: HTTPMethod { return .get }
    
    // 送信するリクエストヘッダー
    var headers: [String: String] { return [:] }
    
    // URLに付けるクエリパラメーター（URL末尾の`?`以降につけるkey=value形式のパラメーター）
    var urlQuery: URLQuery? { return nil }

    // ポストするデータ（リクエストボディ）。GET通信など不要な場合はnilにする
    func makePostData() -> Data? { return nil }
    
    // レスポンスデータのパース前のバリデーション
    func isValidResponse(response: Response) -> Bool { return true }

    // 通信レスポンスをデータモデルに変換する
    func parseResponse(response: Response) throws -> ResponseModel {
        if let string = String(bytes: response.data, encoding: .utf8) {
            return string
        }
        throw ConnectionErrorType.parse
    }
}
```

### リクエストの仕様定義

#### URL、HTTPメソッド

`url: String`、`httpMethod: HTTPMethod` プロパティでリクエストのURL、HTTPメソッドを決めます。

#### ヘッダー

`headers: [String: String]` プロパティでリクエストヘッダーを決めます。  

#### ポストデータ

`func makePostData()` でポストデータを決めます。  
ポストデータがない場合はこの関数で `nil` を返します。 

#### クエリパラメーター

`urlQuery: URLQuery?` プロパティでURLに付与するクエリパラメーターを決めます。  
`URLQuery` 型は `Dictionary` と同じ書き方で以下のように書くことができます。

```swift
var urlQuery: URLQuery? {
    return [
        "id": "123",
        "name": "john",
        "comment": "hello"
    ]
}
```

### レスポンスの仕様定義

#### データのバリデーション
`isValidResponse(response: Response) -> Bool` 関数でデータのバリデーションを行います。ここでのバリデーションはデータパース前の簡易なチェックを想定しています。  
典型的な例として以下のようにステータスコードのチェックを行うことができます。

```swift
func isValidResponse(response: Response) -> Bool {
    // ステータスコード200以外はエラー扱いにする
    return response.statusCode == 200
}
```

特にバリデーションが不要な場合は固定で `true` を返しても問題ありません。

#### パース

まずは受け取るレスポンスの型を `typealias ResponseModel` で指定します。  
次に `parseResponse(response: Response)` 関数でレスポンスデータを指定したレスポンスの型に変換して返します。  

`typealias ResponseModel` の型は任意に指定することができ、`String` や 特定のJSONデータを表すクラスなどを指定することが想定されます。  
`ResponseModel` を`Data` にしてレスポンスデータを変換せずそのまま返したり、`Void` にして何も返さないことも可能です。

パースに失敗した場合、この関数で何らかのエラーを`throw`すると呼び出し元でパースエラーとして扱われます。
 

### 通信の開始

通信の実行は `Connection` クラスを使って行います。  
実装したSpecクラスと通信成功時のコールバック関数をイニシャライザに指定して、`start()` 関数を呼ぶと通信を開始します。

```swift
let spec = SimplestSpec()
Connection(spec) { response in
    print(response)
}.start()
```

### ConnectionSpecをリクエスト仕様とレスポンス仕様に分割する

※ `ConnectionSpec`は`RequestSpec`、`ResponseSpec`２つのプロトコルを継承したプロトコルです。ConnectionSpecを作成する代わりに、RequestSpecを継承したクラスとResponseSpecを継承したクラスを、それぞれ別に作成することもできます。

## 最小構成の通信サンプル (The simplest example)

最小構成の通信サンプルを `Simplest` ディレクトリ内に内に実装しています。

## JSON形式のAPIの読み込み

JSON形式のAPIを読み込む実装例を`GetJSON` ディレクトリ内に内に実装しています。

## 複数のAPIで共通のリクエスト仕様を実装する

ほとんどのプロジェクトでは、API全体で共通のUser-Agentを指定するなど、複数のAPIに共通のリクエスト仕様があります。  
リクエスト仕様を共通化する一つの方法は `ConnectionSpec` の実装に共通の基底クラスを作り、基底クラスを継承して各APIを実装することです。

`CommonRequestSpec` ディレクトリ内にリクエスト仕様の共通化の例を実装しています。

## 複数の通信で共通のふるまいを実装する

ほとんどのプロジェクトでは、通信エラーが起こった場合にポップアップを表示するなど、複数の通信で共通して行うふるまいがあります。  
本ライブラリではそのような共通の振る舞いを通信処理のリスナーとして実装することができます。

リスナーには以下の3種類があります。

- ConnectionListener 通信の開始と終了をフックする
- ConnectionResponseListener レスポンスデータ、パース後のモデルの取得などをフックする
- ConnectionErrorListener ネットワークエラー、パースエラーなどのエラーをフックする

`Listener` ディレクトリ内に各種リスナーのサンプルを実装しています。

### 共通のレスポンス処理

TODO

## 通信中にインジケーターを表示する

通信中にインジケーターを表示する場合 `ConnectionIndicator` を使うことができます。  
`ConnectionIndicator` は `ConnectionListener`プロトコルにより、インジケーターの表示・非表示を管理するクラスで、このクラスを使わずインジケーターの表示制御を独自実装することも可能です。

`ConnectionIndicator` は複数の通信で一つのインジケーターを表示するケースを想定し、単純な通信開始時と終了時の表示非表示切り替えでなく、実行中の通信が0件になったときにインジケーターを非表示にする参照カウント方式で表示制御を行います。

`Indicator` ディレクトリ内にインジケーター表示のサンプルを実装しています。

## リトライ

`ConnectionTask.restart(cloneRequest:, shouldNotify: )` 関数により通信をリトライすることができます。

リトライは `cloneRequest` 引数により、直前のリクエストのコピーを送信するか、もう一度リクエストを作り直すかを選べます。

例えばリクエストパラメーターに現在時刻を含める場合、`cloneRequest = true` ではリトライ時のリクエストパラメーターに前回と同じ時刻が含まれますが、`cloneRequest = false` の場合はリトライ時の現在時刻に変わります。

`Retry` ディレクトリ内にリトライのサンプルを実装しています。

## 通信実装のカスタマイズ

本ライブラリには標準でURLSessionを使った通信実装 `DefaultHTTPConnector` が組み込まれていますが、`HTTPConnector` プロトコルを実装したクラスを作ることで通信処理を自由に実装することができます。

### 通信のモック化

`HTTPConnector` プロトコルを独自実装することで、API処理を実際には通信を行わないモックにすることもできます。

これによりユニットテストで任意のレスポンスを返却したり、リクエストパラメーターのアサーションをしたりすることができます。

`Mock` ディレクトリ内に通信モックのサンプルを実装しています。


## ポーリング（自動更新）
通信が完了したら、N秒後に再度自動で通信を行う。
ポーリングをするには、ポーリングを継続、停止する条件を定める必要がある。

例えば、404エラーやログインエラーをリトライしても、もう一度同じエラーになるだけで意味がない。
ネットワーク

ネットワークエラーの場合はポーリングを行っていい

`Polling` ディレクトリ内に通信ポーリングのサンプルを実装しています。

## Connectionインスタンスのライフサイクル

リトライ、ポーリングなどのときも開放されないようにする

## 401エラーが発生したらアクセストークンをリフレッシュ
再認証を組み込む

## 404エラーを正常系として扱う

データのリストを返すAPIが0件の場合に404エラーを返すことはたまにあります。

## 通信のキャンセル
画面の離脱時に実行していた通信を全てキャンセルする


## URLエンコード処理のカスタマイズ

本ライブラリには標準のURLエンコード実装、`DefaultURLEncoder` が組み込まれていますが、URLエンコードの方法をカスタマイズしたい場合 `URLEncoder` プロトコルを実装したカスタムクラスを作ることでカスタマイズすることができます。
