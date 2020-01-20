[![CocoaPods Compatible](https://img.shields.io/badge/pod-compatible-green.svg)](https://cocoapods.org/pods/AbstractHTTP)

# AbstractHTTP

## 一番シンプルな使用例
https://foo.net にアクセスしてレスポンスの文字列を出力する例。

```swift
HTTP("https://foo.net”).asString {
    print($0)
}
```

## 概要

上の簡単な例に反して、本ライブラリはHTTP通信を簡単にするためのものではありません。  
本ライブラリの目的は **APIクライアントの設計を提供すること** です。

本ライブラリは以下をプロトコルにして抽象化し、自由な実装と再利用ができるようにしています。

* APIのリクエスト・レスポンス仕様
*  HTTP通信処理
* 通信に対するアプリケーションの共通的なふるまい

## APIのリクエスト・レスポンス仕様

一つのAPIはいくつか典型的な固有要素を持っています。  
URL、クエリ、HTTPメソッド、ヘッダー、ボディといったリクエストの仕様と、どういう形のレスポンスが返ってくるかというレスポンスの仕様です。

このライブラリではそれらのAPI仕様をプロトコルにしています。

```swift
// リクエストの仕様
public protocol RequestSpec {
    // リクエスト先のURL
    var url: String { get }
    
    // HTTPメソッド
    var httpMethod: HTTPMethod { get }
    
    // リクエストヘッダー
    var headers: [String: String] { get }
    
    // URLに付与するクエリパラメーター
    var urlQuery: URLQuery? { get }
    
    // リクエストボディ
    func body() -> Data?
}
```

```swift
// レスポンスの仕様
public protocol ResponseSpec {
    // レスポンスのデータ型
    associatedtype ResponseModel

    // パース前のレスポンスデータのバリデーションを行う
    func validate(response: Response) -> Bool

    // HTTPレスポンスをassociated typeに指定した型に変換する
    func parseResponse(response: Response) throws -> ResponseModel
}
```

また、利便性のため`RequestSpec`、`ResponseSpec`両方を継承した `ConnectionSpec` プロトコルを用意しています。

```swift
protocol ConnectionSpec: RequestSpec, ResponseSpec {}
```

１つのAPIに対して `ConnectionSpec` を実装したクラス（以下Specクラス）を１つ作るのが、本ライブラリの基本的な使い方になります。  
REST APIであればURLとHTTPメソッドの組み合わせに対して１つSpecクラスを作成するのがおすすめです。

## HTTP通信処理

HTTP通信処理もタイムアウト時間、キャッシュの仕方、クッキーの扱い、SSL証明書の扱いなどいくつか典型的な固有要素がありますが、本ライブラリではそれらにあまり手出ししません。

HTTP通信処理のプロトコルは以下のように簡単なので、各アプリケーションの要件に従って自由に実装してください。  
UnitTest向けに通信を行わず固定値を返すモックを実装することもできます。

```swift
protocol HTTPConnector {
    func execute(request: Request, complete: @escaping (Response?, Error?) -> Void)
    func cancel()
}
```

とはいえ利便性を考慮して標準の `DefaultHTTPConnector` も用意しているので、シビアで特殊な要件がなければ独自実装をする必要はありません。


## 通信に対するアプリケーションの共通的なふるまい

ほとんどのアプリケーションでは、通信エラーが起こった場合にポップアップを表示するなど、複数の通信で共通して行うふるまいがあります。  
本ライブラリではそのような共通のふるまいを定義するためのプロトコルを以下の3種類用意しています。
これらを使うことで複数のAPIに共通のエラー処理を実装することができます。  

- ConnectionListener 通信の開始と終了をフックする
- ConnectionResponseListener レスポンスデータ、パース後のモデルの取得などをフックする
- ConnectionErrorListener ネットワークエラー、パースエラーなどのエラーをフックする

`Listener` ディレクトリ内に各種リスナーのサンプルを実装しています。

### ConnectionListener

`ConnectionListener` は通信の開始と終了をフックできます。  
通信インジケーターの表示/非表示切り替えなど、通信の開始と終了に共通して行う処理を実装することができます。

### ConnectionResponseListener

`ConnectionResponseListener` は通信データ受信後のいくつかのタイミングをフックし、レスポンスの内容を見てバリデーションエラーを発生させることもできます。

このプロトコルを使うことで複数のAPIに共通のバリデーションを実装したり、複数のAPIのレスポンスデータに対して共通の処理を実装することができます。

### ConnectionErrorListener

`ConnectionErrorListener` ネットワークエラー、バリデーションエラー、パースエラーなど様々なエラーをフックします。
また`ConnectionResponseListener`と併用すると、任意の条件でバリデーションエラーを発生させ、`ConnectionErrorListener`にエラー処理をさせることもできます。


# プログラミングガイド (Programming guide)

## 基本の使い方 (Basic usages)

`ConnectionSpec` プロトコル（またはRequestSpecとResponseSpecプロトコル）を実装したクラスを作ります。  

```swift
// ConnectionSpecの簡単な実装例
class ExampleSpec: ConnectionSpec {
    typealias ResponseModel = String

    var url: String { return "https://example.com/" }
    
    var httpMethod: HTTPMethod { return .get }
    
    var headers: [String: String] { return [:] }
    
    var urlQuery: URLQuery? { return [
        "id": "123",
        "name": "john"
    ]}

    func body() -> Data? { return nil }
    
    func validate(response: Response) -> Bool { 
        // ステータスコード200以外はエラー扱いにする
        return response.statusCode == 200
    }

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

#### リクエストボディ

`body: Data?` プロパティでリクエストボディ（ポストデータ）を決めます。  
ボディがない場合は `nil` を返します。 

#### クエリパラメーター

`urlQuery: URLQuery?` プロパティでURLに付与するクエリパラメーターを決めます。  
`URLQuery` 型はDictionaryLiteralで記載することができます。

### レスポンスの仕様定義

#### レスポンスのバリデーション
`validate(response: Response) -> Bool` 関数でレスポンスのバリデーションを行います。ここでのバリデーションはステータスコードのチェックなど、レスポンスデータパース前の簡易なチェックを想定しています。  
特にバリデーションが不要なら固定で `true` を返しても問題ありません。

#### パース

受け取るレスポンスの型は `typealias ResponseModel` に指定し、`parseResponse(response: Response)` 関数でレスポンスデータを指定した型に変換します。  
`typealias ResponseModel` の型は任意で、`Void` にして何も返さないことも可能です。

また、この関数で何らかのエラーを`throw`すると呼び出し元でパースエラーとして扱われます。

### 通信の開始

通信の実行は `Connection` クラスを使って行います。  
実装したSpecクラスと通信成功時のコールバック関数をイニシャライザに指定して、`start()` 関数を呼ぶと通信を開始します。

```swift
// ConnectionSpecを引数にする例
Connection(ExampleSpec()) {
    print($0)
}.start()
```

```swift
// RequestSpecとResponseSpecを別々に引数にする例
Connection(requestSpec: BarRequestSpec(), responseSpec: BazResponseSpec()) {
    print($0)
}.start()

```

## ConnectionTask (iOS only)

`Connection`はジェネリック型ですが、Swiftではジェネリック型を変数に保持したり、引数に渡すことができないため(*)
`Connection` の関数を外部から呼び出したい場合は、多くの場合 `ConnectionTask` プロトコルを使うことになります。

`ConnectionTask` は `Connection` からジェネリクスが関係しない関数や変数を切り出したプロトコルで、`Connection` は `ConnectionTask` プロトコルを実装しています。

```swift
class Connection<ResponseModel>: ConnectionTask
```

Kotlin (Java)にはそのような制約はなく、ワイルドカードでジェネリクスのパラメーターを指定して変数を作れるため、Android版のAbstractHTTPにはこのプロトコルはありません。

(*) 厳密には変数や引数もジェネリクスにすれば可能です

## 各種イベントの呼び出し順序

### 全体の流れ

1. ConnectionListener.onStart
2. (ネットワークエラーの場合 -> onNetworkErrorへ)
3. ConnectionResponseListener.onReceived (エラーの場合 -> onResponseErrorへ)
4. ResponseSpec.validate (エラーの場合 -> onResponseErrorへ)
5. ResponseSpec.parseResponse  (エラーの場合 -> onParseErrorへ)
6. ConnectionResponseListener.onReceivedModel (エラーの場合 -> onValidationErrorへ)
7. Connection.onSuccess
8. ConnectionResponseListener.afterSuccess
9. ConnectionListener.onEnd

### エラー時の流れ

ConnectionErrorListenerの対応するエラー関数（onNetworkErrorなど）が呼び出された後、以下の順番でイベントが実行されます。

1. ConnectionErrorListener.afterError
2. ConnectionListener.onEnd

## 通信処理のカスタマイズ

本ライブラリには標準でURLSessionを使った通信実装 `DefaultHTTPConnector` が組み込まれていますが、`HTTPConnector` プロトコルを実装したクラスを作ることで通信処理を自由に実装することができます。

### 標準実装のカスタマイズ

標準の通信実装 `DefaultHTTPConnector` は以下のプロパティを変更することができます。

- timeoutInterval (タイムアウト秒数)
- isRedirectEnabled (自動でリダイレクトを行うか)
- cachePolicy (キャッシュの設定)

設定を変更する１つの方法は、以下のように`Connection.httpConnector` を `DefaultHTTPConnector` にキャストして直接プロパティを書き換えることです。

```swift
let connection = Connection(ExampleAPISpec()) 
// 通信タイムアウトの時間を60秒に変更する
(connection.httpConnector as? DefaultHTTPConnector)?.timeoutInterval = 60
```
また、全てのConnectionの通信設定をまとめて変更したい場合は、以下のように `ConnectionConfig.shared.httpConnector` を書き換えます。

```swift
ConnectionConfig.shared.httpConnector = {
    let connector = DefaultHTTPConnector()
    connector.timeoutInterval = 60
    return connector
}
```

### 通信処理の独自実装

さらなる通信処理のカスタマイズを行いたい場合は `HTTPConnector` プロトコルを独自実装し、以下のように`ConnectionConfig.shared.httpConnector` により標準のhttpConnectorに設定してください。

```swift
ConnectionConfig.shared.httpConnector = {
    return YourOriginalHTTPConnector()
}
```

### 通信のモック化

`HTTPConnector` プロトコルを独自実装することで、API処理を実際には通信を行わないモックにすることもできます。  
これによりユニットテストで任意のレスポンスを返却したり、リクエストパラメーターのアサーションをしたりすることができます。

`Mock` ディレクトリ内に通信モックのサンプルを実装しています。

## 通信設定の一括変更

`ConnectionConfig.shared`のプロパティを書き換えることにより、全ての`Connection`の以下のプロパティをまとめて変更することができます。

- httpConnector HTTP通信処理
- urlEncoder URLエンコード処理
- isLogEnabled ログ出力を行うか

```swift
// 全てのConnectonのログ出力を無効化する
ConnectionConfig.shared.isLogEnabled = false
```

ただし、`ConnectionConfig.shared` が決定するのはプロパティの初期値なので、`Connection` インスタンス作成後に個別にさらに別の値に書き換えることは可能です。

## 最小構成の通信サンプル (The simplest example)

最小構成の通信サンプルを `Simplest` ディレクトリ内に内に実装しています。

## JSON形式のAPIの読み込み

JSON形式のAPIを読み込む実装例を`GetJSON` ディレクトリ内に内に実装しています。

## 複数のAPIで共通のリクエスト仕様を実装する

ほとんどのプロジェクトでは、API全体で共通のUser-Agentを指定するなど、複数のAPIに共通のリクエスト仕様があります。  
リクエスト仕様を共通化する一つの方法は `ConnectionSpec` の実装に共通の基底クラスを作り、基底クラスを継承して各APIを実装することです。

`CommonRequestSpec` ディレクトリ内にリクエスト仕様の共通化の例を実装しています。

## 通信中にインジケーターを表示する

`ConnectionIndicator` クラスを使って、通信中に任意のインジケーターを表示することができます。  
このクラスは `ConnectionListener` プロトコルによりインジケーターの表示・非表示を行なっており、`ConnectionListener`プロトコルを使ってインジケーターの表示制御を独自実装することも可能です。

`ConnectionIndicator` は複数の通信で一つのインジケーターを表示するケースを想定し、単純な通信開始時と終了時の表示非表示切り替えでなく、実行中の通信が0件になったときにインジケーターを非表示にする参照カウント方式で表示制御を行います。

`Indicator` ディレクトリ内にインジケーター表示のサンプルを実装しています。

## リトライ

`Connection.restart()` または `Connection.repeatRequest()`関数により通信をリトライすることができます。

`restart`と`repeatRequest`の違いは、リクエストを作り直すか直前のリクエストのコピーを送信するかです。

例えばリクエストパラメーターに動的に現在時刻を含める場合、`restart ` ではリトライ時の時刻がパラメーターに含まれますが、`repeatRequest`では前回送信したリクエストと同じ時刻になります。

`Retry` ディレクトリ内にリトライのサンプルを実装しています。

### リトライ時のコールバックの流れ

`ConnectionResponseListener.onReceived` などのコールバック関数内で通信のリトライをする場合、一連のコールバック関数が呼び出される順番は以下の2パターンがあります。

#### onEndまで呼び出された後に再通信する

アラートを表示してリトライボタンを押した後に再通信する場合など、コールバック関数内でただちに再通信を行わずスレッドを明け渡してから再通信する場合、コールバック関数は一度最後の `ConnectionListener.onEnd` まで全て実行され、その後再通信によりもう一度最初（onStart）からコールバック関数が呼び出されます。

このケースでは `ConnectionListener.onEnd` は合計2回実行されます。

#### コールバックの途中で再通信する

コールバック関数内でただちに再通信を行った場合、1度目の通信のコールバック呼び出しは再通信を実行した時点で中断されます。  
このケースでは2回通信を行いますが `ConnectionListener.onStart` `ConnectionListener.onEnd` は1回しか呼び出されず、リスナーに対しては1回しか通信が行われていないようにふるまいます。

また、コールバック内で一度スレッドを明け渡した後に再通信を行う場合に `ConnectionListener.onEnd ` を1回しか呼び出したくないケースでは、再通信の前に `Connection.interrupt()` を実行すると、一度目の通信のコールバック呼び出しが中断されます。  

ただし`Connection.interrupt()` を実行すると、その後`restart`か`repeatRequest`により再通信を行うか、`Connection.breakInterruption()` を行わないと、`ConnectionListener.onEnd`が実行されないので注意してください。

## ポーリング（自動更新）

`Polling` クラスを使って、通信のポーリング（定期的な自動更新）を行うことができます。  
このクラスは `ConnectionListener` プロトコルによりポーリングを行なっており、`ConnectionListener`プロトコルを使ってポーリングを独自実装することも可能です。

`Polling` クラスは通信成功またはネットワークエラー後、任意のインターバルの後にイニシャライザで指定したコールバックを呼び出すので、コールバック内で再度通信処理を実行することでポーリングを行うことができます。

このクラスがポーリングを継続する条件は、通信成功かネットワークエラーになることで、それ以外のバリデーションエラーやパースエラーが発生した場合ポーリングは停止します。

`Polling` ディレクトリ内に通信ポーリングのサンプルを実装しています。

## Connectionインスタンスのライフサイクル

Swiftではローカル変数が関数スコープを抜けると解放されてしまいますが、`Connection` のインスタンスは通信が終わるまで `ConnectionHolder` に保持されるため、スコープを抜けても解放されず残ります。

```swift
func request() {
    Connection(Spec()) { response in
        self.response = response
    }.start()
    // Connection インスタンスは関数を抜けても解放されない
}
```

ただし通信完了後には `Connection` が解放されてしまうので、通信完了後しばらく間を空けてからリトライするようなケースでは何らかの形で `Connection`インスタンスを保持しておく必要があります。

`ConnectionHolder` は標準では一つの共有オブジェクトが全ての `Connection` に対して使われますが、`Connection.holder` プロパティをセットすることで、任意のオブジェクトを使うこともできます。

## 通信のキャンセル

`Connection.cancel()` 関数で実行中の通信をキャンセルすることができます。  
この関数は `ConnectionTask` プロトコルからも呼び出すことができます。

また、`Connection`は`ConnectionHolder`に保持されるため、`ConnectionHolder`を通じてまとめて複数の通信をキャンセルすることもできます。

標準の `ConnectionHolder` の共有オブジェクトを使っている場合、以下のコードで画面離脱時に全ての通信をキャンセルすることができます。

```swift
override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    // 画面離脱時に全ての通信をキャンセルする
    ConnectionHolder.shared.cancelAll()
}
```

`Cancel` ディレクトリ内にキャンセルのサンプルを実装しています。

### キャンセル時のコールバック呼び出し

`Connection.cancel()` 関数を実行すると、正常系のコールバック呼び出しはスキップされ、以下のコールバック関数が実行されます。

1. ConnectionErrorListener.onCanceled
2. ConnectionErrorListener.afterError
3. ConnectionListener.onEnd

`ConnectionResponseListener.onReceived` など正常系のコールバックの途中でキャンセルした場合も、以降の正常系のコールバック呼び出しがスキップされ、上記のコールバックが呼び出されます。

## 404エラーを正常系として扱う

レスポンスデータのパース処理は、多くの場合バイナリデータを文字列にしたりJSONデータをオブジェクトにマッピングしたりといった規則的なマッピングになりますが、実装内容は自由なので、特定の条件で例外的なパースを行うこともできます。

データリストを返すAPIがレスポンスが0件の場合に404エラーを返す仕様はたまにありますが、そのようなケースをエラーではなく0件の正常なレスポンスとして扱いたい場合、パース処理を以下のようにすることで実現できます。


```swift
func parseResponse(response: Response) throws -> ResponseModel {
    // 404エラーの場合は空配列にする
    if response.statusCode == 404 {
        return []
    }
    // それ以外はJSONをパースしてString配列を取り出す
    return try JSONDecoder().decode([String].self, from: response.data)
}
```

## 401エラーが発生したらアクセストークンをリフレッシュする

今まで説明した機能の組み合わせで、通信で401エラーが発生したらアクセストークンのリフレッシュを行い、トークンリフレッシュに成功したら、同じ通信をリトライする機能を実装できます。

まず、HTTPステータスコード401のハンドリングは以下の2箇所のどちらかで行なえます。

- `ConnectionResponseListener.onReceived`
- `ConnectionErrorListener.onResponseError`

`ConnectionErrorListener.onResponseError`で401エラーのハンドリングを行う場合は、401ステータスをレスポンスエラー扱いにする必要があり、`ConnectionResponseListener.onReceived`または`ResponseSpec.validate`でHTTPステータスが401の場合に `false` を返すようにします。

```swift
func validate(response: Response) -> Bool {
    // ステータスコード401はエラーにする
    return response.statusCode != 401
}
```

次に`onReceived`または`onResponseError`でステータスコードが401の場合にトークンのリフレッシュ処理を行い、リフレッシュが完了したら引数で渡された`connection`を`restart`により再通信させます。

また、再通信を行うと、401エラーが発生した最初の通信と再通信で `onEnd` が2回呼ばれてしまいますが、これを回避するために再通信を行う前に `Connection.interrupt` を実行します。

`TokenRefresh` ディレクトリ内にトークンリフレッシュのサンプルを実装しています。

## URLエンコード処理のカスタマイズ

本ライブラリには標準のURLエンコード実装、`DefaultURLEncoder` が組み込まれていますが、URLエンコードの方法をカスタマイズしたい場合 `URLEncoder` プロトコルを実装したカスタムクラスを作ることでカスタマイズすることができます。

## 簡易インターフェース (Convenient interface)

Specクラスを実装せず簡易に通信するためのインターフェース`HTTP`を用意しています。

このクラスは `Connection`と`ConnectionSpec`をラップしてメソッド経由で様々な指定ができるようにしたもので、`Connection` でできることはこちらのインターフェースでもできます。

`Convenient` ディレクトリ内に簡易インターフェースのサンプルを実装しています。

### 使い方

1. イニシャライザでURLを指定して`HTTP`オブジェクトを作ります。
2. `ConnectionSpec`に定義する各種リクエストの情報、レスポンスの処理および、`Connection`の書き換え可能なプロパティは`HTTP`のメソッドを使って設定します。
3. 最後に`HTTP`の以下の`as`始まりのメソッドでレスポンスデータを取得します。
	- asString String型で取得します。文字コードを指定可能です
	- asData Data型で取得します
	- asResponse Response型で取得します
	- asDecodable Decodableの型を指定して、その型にJSONをマッピングし取得します
	- asModel 任意の型とその型への変換処理を指定してデータを取得します

	
### 最も簡単なGET通信の例

```swift
HTTP("https://foo.net”).asString {
	print($0)
}
```

### 各種設定を行ったPOST通信の例

```swift
HTTP("https://foo.net”)
    .httpMethod(.post)
    .headers(["Content-Type": "application/json"])
    .urlQuery(["key": "value"])
    .body(data)
    .addListener(listener)
    .asDecodable(User.self) { user in
    	print(user.name)
    }
```

### DefaultHTTPConnectorの設定

`httpConnector` に標準の`DefaultHTTPConnector`を使用している場合、`HTTP.setupDefaultHTTPConnector` メソッドで`DefaultHTTPConnector`のプロパティを書き換えることができます。