function handler(event) {
    // cloudfront は s3 にforward するだけなので foo にアクセスされても foo/index.html を返さない。
    // よって foo や foo/ にアクセスされた場合に foo/index.html を返すようにする。
    // なお js, css なども同じドメインにアクセスされるため、拡張子が存在しない場合にのみ index.html を付加する。

    var request = event.request;
    var uri = request.uri;
    // Check whether the URI is missing a file name.
    if (uri.endsWith('/')) {
        request.uri += 'index.html';
    }
    // Check whether the URI is missing a file extension.
    else if (!uri.includes('.')) {
        request.uri += '/index.html';
    }
    return request;
}