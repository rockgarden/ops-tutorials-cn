# curl

```txt

equest URL:
https://www.eastcomccmp.top/egitlab/api/graphql
Request Method:
POST
Status Code:
200 OK
Remote Address:
47.93.92.72:443
Referrer Policy:
strict-origin-when-cross-origin
```

```html
<!doctypehtml>
<html lang="zh-cn">
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <meta name="data-spm" content="a3c0e">
    <title>405</title>
    <style>
        a,body,div,h2,html,p {
            margin: 0;
            padding: 0
        }

        a {
            text-decoration: none;
            color: #3b6ea3
        }

        .container {
            width: 1000px;
            margin: auto;
            color: #696969
        }

        .header {
            padding: 110px 0
        }

        .header .message {
            height: 36px;
            padding-left: 120px;
            background: url(https://errors.aliyun.com/images/TB1TpamHpXXXXaJXXXXeB7nYVXX-104-162.png) no-repeat 0 -128px;
            line-height: 36px
        }

        .main {
            padding: 50px 0;
            background: #f4f5f7
        }

        #block_image {
            position: relative;
            left: 120px
        }
    </style>
    <body data-spm="7663354">
        <div data-spm="1998410538">
            <div class="header">
                <div class="container">
                    <div class="message">
                        <div id="block_message"></div>
                        <div>
                            <span id="block_url_tips"></span>
                            <strong id="url"></strong>
                        </div>
                        <div>
                            <span id="block_time_tips"></span>
                            <strong id="time"></strong>
                        </div>
                        <div>
                            <span id="block_traceid_tips"></span>
                            <strong id="traceid"></strong>
                        </div>
                    </div>
                </div>
            </div>
            <div class="main">
                <div class="container">
                    <img id="block_image">
                </div>
            </div>
        </div>
        <script>
            function getRenderData() {
                var e = document.getElementById("renderData");
                return JSON.parse(e.innerHTML)
            }
            function convertTimestampToString(e) {
                e = parseInt(e, 10),
                e = new Date(e);
                return e.getFullYear() + "-" + ("0" + (e.getMonth() + 1)).slice(-2) + "-" + ("0" + e.getDate()).slice(-2) + " " + ("0" + e.getHours()).slice(-2) + ":" + ("0" + e.getMinutes()).slice(-2) + ":" + ("0" + e.getSeconds()).slice(-2)
            }
            var en_tips = {
                block_message: "Sorry, your request has been blocked as it may cause potential threats to the server's security.",
                block_url_tips: "Current URL: ",
                block_time_tips: "Request Time: ",
                block_traceid_tips: "Your Request ID is: "
            }
              , cn_tips = {
                block_message: "很抱歉，由于您访问的URL有可能对网站造成安全威胁，您的访问被阻断。",
                block_url_tips: "当前网址: ",
                block_time_tips: "请求时间: ",
                block_traceid_tips: "您的请求ID是: "
            };
            window.onload = function() {
                var t = getRenderData()
                  , n = "cn";
                try {
                    navigator.language.startsWith("zh") || (n = "en")
                } catch (e) {
                    t.lang && (n = t.lang)
                }
                if (t) {
                    var e, i = cn_tips, r = document.getElementById("block_image");
                    for (e in "en" === n ? (i = en_tips,
                    r.src = "https://g.alicdn.com/sd-base/static/1.0.5/image/405.png",
                    r.id = "en_block") : r.src = "https://errors.aliyun.com/images/TB15QGaHpXXXXXOaXXXXia39XXX-660-117.png",
                    i)
                        document.getElementById(e).innerText = i[e];
                    n = t.traceid,
                    r = n.slice(8, 21);
                    document.getElementById("traceid").innerText = n,
                    document.getElementById("url").innerText = location.href.split("?")[0],
                    document.getElementById("time").innerText = convertTimestampToString(r)
                }
            }
        </script>
        <textarea id="renderData" style="display:none">{"traceid":"2760820917524831065174093ef69d","lang":"cn"}</textarea>
```

```txt
Request URL:
https://www.eastcomccmp.top/egitlab/api/graphql?query=query%20getPipelineIid(%24fullPath%3A%20ID!%2C%20%24sha%3A%20String!)%20%7B%20project(fullPath%3A%20%24fullPath)%20%7B%20id%20pipeline(sha%3A%20%24sha)%20%7B%20id%20iid%20__typename%20%7D%20__typename%20%7D%20%7D&operationName=getPipelineIid&variables=%7B%22fullPath%22%3A%22root%2Fea-hz-travel%22%2C%22sha%22%3A%22f5d11a59ad41536be7516b1752dc40213a611a0c%22%7D
Request Method:
GET
Status Code:
304 Not Modified
Remote Address:
47.93.92.72:443
Referrer Policy:
strict-origin-when-cross-origin

Response:
{
    "data": {
        "project": {
            "id": "gid://gitlab/Project/219",
            "pipeline": null,
            "__typename": "Project"
        }
    }
}
```

```bash
curl $'https://www.eastcomccmp.top/egitlab/api/graphql?query=query%20getPipelineIid(%24fullPath%3A%20ID\u0021%2C%20%24sha%3A%20String\u0021)%20%7B%20project(fullPath%3A%20%24fullPath)%20%7B%20id%20pipeline(sha%3A%20%24sha)%20%7B%20id%20iid%20__typename%20%7D%20__typename%20%7D%20%7D&operationName=getPipelineIid&variables=%7B%22fullPath%22%3A%22root%2Fea-hz-travel%22%2C%22sha%22%3A%22f5d11a59ad41536be7516b1752dc40213a611a0c%22%7D' \
  -H 'Accept-Language: zh-CN,zh;q=0.9' \
  -H 'Connection: keep-alive' \
  -H 'Cookie: _gitlab_session=fe681247e580a7f257fae085b442205b; preferred_language=zh_CN; acw_tc=2760820217524818480614973e49572ed1d7a6978b0f8fc4a373b4865a7355; known_sign_in=eDFabTVEUFNWVjlScG5jQW8zQVJKVnpsaGc2T3lGNWcxMU1HOTVKZ0pEUk1aakE5TVFWcUZNRmN3VXMyS0VlYk1uM3VQU0JhM1NZYUh5bTMyN2tOc0x2MG5HOFV0UHdnY0xlT29WeWRFeGZ0THpKTllNNXF0cm1tUDVUU0lVTVYtLXJNbjlUZ0JobHhSL2kzSld0YjYzd3c9PQ%3D%3D--a8b0a6d41df51d57bd5ac066d722e5adaf29944b; event_filter=all' \
  -H 'If-None-Match: W/"51cd776a653c966241ea7ee2fd61741b"' \
  -H 'Referer: https://www.eastcomccmp.top/egitlab/root/ea-hz-travel/-/ci/editor?branch_name=master' \
  -H 'Sec-Fetch-Dest: empty' \
  -H 'Sec-Fetch-Mode: cors' \
  -H 'Sec-Fetch-Site: same-origin' \
  -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36' \
  -H 'accept: */*' \
  -H 'content-type: application/json' \
  -H 'sec-ch-ua: "Chromium";v="116", "Not)A;Brand";v="24", "Google Chrome";v="116"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'sec-ch-ua-platform: "macOS"' \
  -H 'x-csrf-token: lNOdKs6IZBu9F9c1uAYbvaHZ1lp3TNIO0OtbUt3FvC-jui1v6fVXPH8mMN_CFsO-GNg-m-XoY-ygHEpnB7RpNg' \
  -H 'x-gitlab-feature-category: pipeline_composition' \
  -H 'x-gitlab-graphql-feature-correlation: verify/ci/pipeline-graph' \
  -H 'x-gitlab-graphql-resource-etag: /egitlab/api/graphql:pipelines/sha/f5d11a59ad41536be7516b1752dc40213a611a0c' \
  -H 'x-gitlab-version: 17.11.4' \
  -H 'x-requested-with: XMLHttpRequest' \
  --compressed ;
curl $'https://www.eastcomccmp.top/egitlab/api/graphql?query=query%20getPipelineIid(%24fullPath%3A%20ID\u0021%2C%20%24sha%3A%20String\u0021)%20%7B%20project(fullPath%3A%20%24fullPath)%20%7B%20id%20pipeline(sha%3A%20%24sha)%20%7B%20id%20iid%20__typename%20%7D%20__typename%20%7D%20%7D&operationName=getPipelineIid&variables=%7B%22fullPath%22%3A%22root%2Fea-hz-travel%22%2C%22sha%22%3A%22f5d11a59ad41536be7516b1752dc40213a611a0c%22%7D' \
  -H 'Accept-Language: zh-CN,zh;q=0.9' \
  -H 'Connection: keep-alive' \
  -H 'Cookie: _gitlab_session=fe681247e580a7f257fae085b442205b; preferred_language=zh_CN; acw_tc=2760820217524818480614973e49572ed1d7a6978b0f8fc4a373b4865a7355; known_sign_in=eDFabTVEUFNWVjlScG5jQW8zQVJKVnpsaGc2T3lGNWcxMU1HOTVKZ0pEUk1aakE5TVFWcUZNRmN3VXMyS0VlYk1uM3VQU0JhM1NZYUh5bTMyN2tOc0x2MG5HOFV0UHdnY0xlT29WeWRFeGZ0THpKTllNNXF0cm1tUDVUU0lVTVYtLXJNbjlUZ0JobHhSL2kzSld0YjYzd3c9PQ%3D%3D--a8b0a6d41df51d57bd5ac066d722e5adaf29944b; event_filter=all' \
  -H 'If-None-Match: W/"51cd776a653c966241ea7ee2fd61741b"' \
  -H 'Referer: https://www.eastcomccmp.top/egitlab/root/ea-hz-travel/-/ci/editor?branch_name=master' \
  -H 'Sec-Fetch-Dest: empty' \
  -H 'Sec-Fetch-Mode: cors' \
  -H 'Sec-Fetch-Site: same-origin' \
  -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36' \
  -H 'accept: */*' \
  -H 'content-type: application/json' \
  -H 'sec-ch-ua: "Chromium";v="116", "Not)A;Brand";v="24", "Google Chrome";v="116"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'sec-ch-ua-platform: "macOS"' \
  -H 'x-csrf-token: lNOdKs6IZBu9F9c1uAYbvaHZ1lp3TNIO0OtbUt3FvC-jui1v6fVXPH8mMN_CFsO-GNg-m-XoY-ygHEpnB7RpNg' \
  -H 'x-gitlab-feature-category: pipeline_composition' \
  -H 'x-gitlab-graphql-feature-correlation: verify/ci/pipeline-graph' \
  -H 'x-gitlab-graphql-resource-etag: /egitlab/api/graphql:pipelines/sha/f5d11a59ad41536be7516b1752dc40213a611a0c' \
  -H 'x-gitlab-version: 17.11.4' \
  -H 'x-requested-with: XMLHttpRequest' \
  --compressed ;
curl $'https://www.eastcomccmp.top/egitlab/api/graphql?query=query%20getPipelineIid(%24fullPath%3A%20ID\u0021%2C%20%24sha%3A%20String\u0021)%20%7B%20project(fullPath%3A%20%24fullPath)%20%7B%20id%20pipeline(sha%3A%20%24sha)%20%7B%20id%20iid%20__typename%20%7D%20__typename%20%7D%20%7D&operationName=getPipelineIid&variables=%7B%22fullPath%22%3A%22root%2Fea-hz-travel%22%2C%22sha%22%3A%22f5d11a59ad41536be7516b1752dc40213a611a0c%22%7D' \
  -H 'Accept-Language: zh-CN,zh;q=0.9' \
  -H 'Connection: keep-alive' \
  -H 'Cookie: _gitlab_session=fe681247e580a7f257fae085b442205b; preferred_language=zh_CN; acw_tc=2760820217524818480614973e49572ed1d7a6978b0f8fc4a373b4865a7355; known_sign_in=eDFabTVEUFNWVjlScG5jQW8zQVJKVnpsaGc2T3lGNWcxMU1HOTVKZ0pEUk1aakE5TVFWcUZNRmN3VXMyS0VlYk1uM3VQU0JhM1NZYUh5bTMyN2tOc0x2MG5HOFV0UHdnY0xlT29WeWRFeGZ0THpKTllNNXF0cm1tUDVUU0lVTVYtLXJNbjlUZ0JobHhSL2kzSld0YjYzd3c9PQ%3D%3D--a8b0a6d41df51d57bd5ac066d722e5adaf29944b; event_filter=all' \
  -H 'If-None-Match: W/"51cd776a653c966241ea7ee2fd61741b"' \
  -H 'Referer: https://www.eastcomccmp.top/egitlab/root/ea-hz-travel/-/ci/editor?branch_name=master' \
  -H 'Sec-Fetch-Dest: empty' \
  -H 'Sec-Fetch-Mode: cors' \
  -H 'Sec-Fetch-Site: same-origin' \
  -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36' \
  -H 'accept: */*' \
  -H 'content-type: application/json' \
  -H 'sec-ch-ua: "Chromium";v="116", "Not)A;Brand";v="24", "Google Chrome";v="116"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'sec-ch-ua-platform: "macOS"' \
  -H 'x-csrf-token: lNOdKs6IZBu9F9c1uAYbvaHZ1lp3TNIO0OtbUt3FvC-jui1v6fVXPH8mMN_CFsO-GNg-m-XoY-ygHEpnB7RpNg' \
  -H 'x-gitlab-feature-category: pipeline_composition' \
  -H 'x-gitlab-graphql-feature-correlation: verify/ci/pipeline-graph' \
  -H 'x-gitlab-graphql-resource-etag: /egitlab/api/graphql:pipelines/sha/f5d11a59ad41536be7516b1752dc40213a611a0c' \
  -H 'x-gitlab-version: 17.11.4' \
  -H 'x-requested-with: XMLHttpRequest' \
  --compressed ;
curl $'https://www.eastcomccmp.top/egitlab/api/graphql?query=query%20getPipelineIid(%24fullPath%3A%20ID\u0021%2C%20%24sha%3A%20String\u0021)%20%7B%20project(fullPath%3A%20%24fullPath)%20%7B%20id%20pipeline(sha%3A%20%24sha)%20%7B%20id%20iid%20__typename%20%7D%20__typename%20%7D%20%7D&operationName=getPipelineIid&variables=%7B%22fullPath%22%3A%22root%2Fea-hz-travel%22%2C%22sha%22%3A%22f5d11a59ad41536be7516b1752dc40213a611a0c%22%7D' \
  -H 'Accept-Language: zh-CN,zh;q=0.9' \
  -H 'Connection: keep-alive' \
  -H 'Cookie: _gitlab_session=fe681247e580a7f257fae085b442205b; preferred_language=zh_CN; acw_tc=2760820217524818480614973e49572ed1d7a6978b0f8fc4a373b4865a7355; known_sign_in=eDFabTVEUFNWVjlScG5jQW8zQVJKVnpsaGc2T3lGNWcxMU1HOTVKZ0pEUk1aakE5TVFWcUZNRmN3VXMyS0VlYk1uM3VQU0JhM1NZYUh5bTMyN2tOc0x2MG5HOFV0UHdnY0xlT29WeWRFeGZ0THpKTllNNXF0cm1tUDVUU0lVTVYtLXJNbjlUZ0JobHhSL2kzSld0YjYzd3c9PQ%3D%3D--a8b0a6d41df51d57bd5ac066d722e5adaf29944b; event_filter=all' \
  -H 'If-None-Match: W/"51cd776a653c966241ea7ee2fd61741b"' \
  -H 'Referer: https://www.eastcomccmp.top/egitlab/root/ea-hz-travel/-/ci/editor?branch_name=master' \
  -H 'Sec-Fetch-Dest: empty' \
  -H 'Sec-Fetch-Mode: cors' \
  -H 'Sec-Fetch-Site: same-origin' \
  -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36' \
  -H 'accept: */*' \
  -H 'content-type: application/json' \
  -H 'sec-ch-ua: "Chromium";v="116", "Not)A;Brand";v="24", "Google Chrome";v="116"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'sec-ch-ua-platform: "macOS"' \
  -H 'x-csrf-token: lNOdKs6IZBu9F9c1uAYbvaHZ1lp3TNIO0OtbUt3FvC-jui1v6fVXPH8mMN_CFsO-GNg-m-XoY-ygHEpnB7RpNg' \
  -H 'x-gitlab-feature-category: pipeline_composition' \
  -H 'x-gitlab-graphql-feature-correlation: verify/ci/pipeline-graph' \
  -H 'x-gitlab-graphql-resource-etag: /egitlab/api/graphql:pipelines/sha/f5d11a59ad41536be7516b1752dc40213a611a0c' \
  -H 'x-gitlab-version: 17.11.4' \
  -H 'x-requested-with: XMLHttpRequest' \
  --compressed ;
curl $'https://www.eastcomccmp.top/egitlab/api/graphql?query=query%20getPipelineIid(%24fullPath%3A%20ID\u0021%2C%20%24sha%3A%20String\u0021)%20%7B%20project(fullPath%3A%20%24fullPath)%20%7B%20id%20pipeline(sha%3A%20%24sha)%20%7B%20id%20iid%20__typename%20%7D%20__typename%20%7D%20%7D&operationName=getPipelineIid&variables=%7B%22fullPath%22%3A%22root%2Fea-hz-travel%22%2C%22sha%22%3A%22f5d11a59ad41536be7516b1752dc40213a611a0c%22%7D' \
  -H 'Accept-Language: zh-CN,zh;q=0.9' \
  -H 'Connection: keep-alive' \
  -H 'Cookie: _gitlab_session=fe681247e580a7f257fae085b442205b; preferred_language=zh_CN; acw_tc=2760820217524818480614973e49572ed1d7a6978b0f8fc4a373b4865a7355; known_sign_in=eDFabTVEUFNWVjlScG5jQW8zQVJKVnpsaGc2T3lGNWcxMU1HOTVKZ0pEUk1aakE5TVFWcUZNRmN3VXMyS0VlYk1uM3VQU0JhM1NZYUh5bTMyN2tOc0x2MG5HOFV0UHdnY0xlT29WeWRFeGZ0THpKTllNNXF0cm1tUDVUU0lVTVYtLXJNbjlUZ0JobHhSL2kzSld0YjYzd3c9PQ%3D%3D--a8b0a6d41df51d57bd5ac066d722e5adaf29944b; event_filter=all' \
  -H 'If-None-Match: W/"51cd776a653c966241ea7ee2fd61741b"' \
  -H 'Referer: https://www.eastcomccmp.top/egitlab/root/ea-hz-travel/-/ci/editor?branch_name=master' \
  -H 'Sec-Fetch-Dest: empty' \
  -H 'Sec-Fetch-Mode: cors' \
  -H 'Sec-Fetch-Site: same-origin' \
  -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36' \
  -H 'accept: */*' \
  -H 'content-type: application/json' \
  -H 'sec-ch-ua: "Chromium";v="116", "Not)A;Brand";v="24", "Google Chrome";v="116"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'sec-ch-ua-platform: "macOS"' \
  -H 'x-csrf-token: lNOdKs6IZBu9F9c1uAYbvaHZ1lp3TNIO0OtbUt3FvC-jui1v6fVXPH8mMN_CFsO-GNg-m-XoY-ygHEpnB7RpNg' \
  -H 'x-gitlab-feature-category: pipeline_composition' \
  -H 'x-gitlab-graphql-feature-correlation: verify/ci/pipeline-graph' \
  -H 'x-gitlab-graphql-resource-etag: /egitlab/api/graphql:pipelines/sha/f5d11a59ad41536be7516b1752dc40213a611a0c' \
  -H 'x-gitlab-version: 17.11.4' \
  -H 'x-requested-with: XMLHttpRequest' \
  --compressed ;
curl $'https://www.eastcomccmp.top/egitlab/api/graphql?query=query%20getPipelineIid(%24fullPath%3A%20ID\u0021%2C%20%24sha%3A%20String\u0021)%20%7B%20project(fullPath%3A%20%24fullPath)%20%7B%20id%20pipeline(sha%3A%20%24sha)%20%7B%20id%20iid%20__typename%20%7D%20__typename%20%7D%20%7D&operationName=getPipelineIid&variables=%7B%22fullPath%22%3A%22root%2Fea-hz-travel%22%2C%22sha%22%3A%22f5d11a59ad41536be7516b1752dc40213a611a0c%22%7D' \
  -H 'Accept-Language: zh-CN,zh;q=0.9' \
  -H 'Connection: keep-alive' \
  -H 'Cookie: _gitlab_session=fe681247e580a7f257fae085b442205b; preferred_language=zh_CN; acw_tc=2760820217524818480614973e49572ed1d7a6978b0f8fc4a373b4865a7355; known_sign_in=eDFabTVEUFNWVjlScG5jQW8zQVJKVnpsaGc2T3lGNWcxMU1HOTVKZ0pEUk1aakE5TVFWcUZNRmN3VXMyS0VlYk1uM3VQU0JhM1NZYUh5bTMyN2tOc0x2MG5HOFV0UHdnY0xlT29WeWRFeGZ0THpKTllNNXF0cm1tUDVUU0lVTVYtLXJNbjlUZ0JobHhSL2kzSld0YjYzd3c9PQ%3D%3D--a8b0a6d41df51d57bd5ac066d722e5adaf29944b; event_filter=all' \
  -H 'If-None-Match: W/"51cd776a653c966241ea7ee2fd61741b"' \
  -H 'Referer: https://www.eastcomccmp.top/egitlab/root/ea-hz-travel/-/ci/editor?branch_name=master' \
  -H 'Sec-Fetch-Dest: empty' \
  -H 'Sec-Fetch-Mode: cors' \
  -H 'Sec-Fetch-Site: same-origin' \
  -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36' \
  -H 'accept: */*' \
  -H 'content-type: application/json' \
  -H 'sec-ch-ua: "Chromium";v="116", "Not)A;Brand";v="24", "Google Chrome";v="116"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'sec-ch-ua-platform: "macOS"' \
  -H 'x-csrf-token: lNOdKs6IZBu9F9c1uAYbvaHZ1lp3TNIO0OtbUt3FvC-jui1v6fVXPH8mMN_CFsO-GNg-m-XoY-ygHEpnB7RpNg' \
  -H 'x-gitlab-feature-category: pipeline_composition' \
  -H 'x-gitlab-graphql-feature-correlation: verify/ci/pipeline-graph' \
  -H 'x-gitlab-graphql-resource-etag: /egitlab/api/graphql:pipelines/sha/f5d11a59ad41536be7516b1752dc40213a611a0c' \
  -H 'x-gitlab-version: 17.11.4' \
  -H 'x-requested-with: XMLHttpRequest' \
  --compressed ;
curl $'https://www.eastcomccmp.top/egitlab/api/graphql?query=query%20getPipelineIid(%24fullPath%3A%20ID\u0021%2C%20%24sha%3A%20String\u0021)%20%7B%20project(fullPath%3A%20%24fullPath)%20%7B%20id%20pipeline(sha%3A%20%24sha)%20%7B%20id%20iid%20__typename%20%7D%20__typename%20%7D%20%7D&operationName=getPipelineIid&variables=%7B%22fullPath%22%3A%22root%2Fea-hz-travel%22%2C%22sha%22%3A%22f5d11a59ad41536be7516b1752dc40213a611a0c%22%7D' \
  -H 'Accept-Language: zh-CN,zh;q=0.9' \
  -H 'Connection: keep-alive' \
  -H 'Cookie: _gitlab_session=fe681247e580a7f257fae085b442205b; preferred_language=zh_CN; acw_tc=2760820217524818480614973e49572ed1d7a6978b0f8fc4a373b4865a7355; known_sign_in=eDFabTVEUFNWVjlScG5jQW8zQVJKVnpsaGc2T3lGNWcxMU1HOTVKZ0pEUk1aakE5TVFWcUZNRmN3VXMyS0VlYk1uM3VQU0JhM1NZYUh5bTMyN2tOc0x2MG5HOFV0UHdnY0xlT29WeWRFeGZ0THpKTllNNXF0cm1tUDVUU0lVTVYtLXJNbjlUZ0JobHhSL2kzSld0YjYzd3c9PQ%3D%3D--a8b0a6d41df51d57bd5ac066d722e5adaf29944b; event_filter=all' \
  -H 'If-None-Match: W/"51cd776a653c966241ea7ee2fd61741b"' \
  -H 'Referer: https://www.eastcomccmp.top/egitlab/root/ea-hz-travel/-/ci/editor?branch_name=master' \
  -H 'Sec-Fetch-Dest: empty' \
  -H 'Sec-Fetch-Mode: cors' \
  -H 'Sec-Fetch-Site: same-origin' \
  -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36' \
  -H 'accept: */*' \
  -H 'content-type: application/json' \
  -H 'sec-ch-ua: "Chromium";v="116", "Not)A;Brand";v="24", "Google Chrome";v="116"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'sec-ch-ua-platform: "macOS"' \
  -H 'x-csrf-token: lNOdKs6IZBu9F9c1uAYbvaHZ1lp3TNIO0OtbUt3FvC-jui1v6fVXPH8mMN_CFsO-GNg-m-XoY-ygHEpnB7RpNg' \
  -H 'x-gitlab-feature-category: pipeline_composition' \
  -H 'x-gitlab-graphql-feature-correlation: verify/ci/pipeline-graph' \
  -H 'x-gitlab-graphql-resource-etag: /egitlab/api/graphql:pipelines/sha/f5d11a59ad41536be7516b1752dc40213a611a0c' \
  -H 'x-gitlab-version: 17.11.4' \
  -H 'x-requested-with: XMLHttpRequest' \
  --compressed ;
curl $'https://www.eastcomccmp.top/egitlab/api/graphql?query=query%20getPipelineIid(%24fullPath%3A%20ID\u0021%2C%20%24sha%3A%20String\u0021)%20%7B%20project(fullPath%3A%20%24fullPath)%20%7B%20id%20pipeline(sha%3A%20%24sha)%20%7B%20id%20iid%20__typename%20%7D%20__typename%20%7D%20%7D&operationName=getPipelineIid&variables=%7B%22fullPath%22%3A%22root%2Fea-hz-travel%22%2C%22sha%22%3A%22f5d11a59ad41536be7516b1752dc40213a611a0c%22%7D' \
  -H 'Accept-Language: zh-CN,zh;q=0.9' \
  -H 'Connection: keep-alive' \
  -H 'Cookie: _gitlab_session=fe681247e580a7f257fae085b442205b; preferred_language=zh_CN; acw_tc=2760820217524818480614973e49572ed1d7a6978b0f8fc4a373b4865a7355; known_sign_in=eDFabTVEUFNWVjlScG5jQW8zQVJKVnpsaGc2T3lGNWcxMU1HOTVKZ0pEUk1aakE5TVFWcUZNRmN3VXMyS0VlYk1uM3VQU0JhM1NZYUh5bTMyN2tOc0x2MG5HOFV0UHdnY0xlT29WeWRFeGZ0THpKTllNNXF0cm1tUDVUU0lVTVYtLXJNbjlUZ0JobHhSL2kzSld0YjYzd3c9PQ%3D%3D--a8b0a6d41df51d57bd5ac066d722e5adaf29944b; event_filter=all' \
  -H 'If-None-Match: W/"51cd776a653c966241ea7ee2fd61741b"' \
  -H 'Referer: https://www.eastcomccmp.top/egitlab/root/ea-hz-travel/-/ci/editor?branch_name=master' \
  -H 'Sec-Fetch-Dest: empty' \
  -H 'Sec-Fetch-Mode: cors' \
  -H 'Sec-Fetch-Site: same-origin' \
  -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36' \
  -H 'accept: */*' \
  -H 'content-type: application/json' \
  -H 'sec-ch-ua: "Chromium";v="116", "Not)A;Brand";v="24", "Google Chrome";v="116"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'sec-ch-ua-platform: "macOS"' \
  -H 'x-csrf-token: lNOdKs6IZBu9F9c1uAYbvaHZ1lp3TNIO0OtbUt3FvC-jui1v6fVXPH8mMN_CFsO-GNg-m-XoY-ygHEpnB7RpNg' \
  -H 'x-gitlab-feature-category: pipeline_composition' \
  -H 'x-gitlab-graphql-feature-correlation: verify/ci/pipeline-graph' \
  -H 'x-gitlab-graphql-resource-etag: /egitlab/api/graphql:pipelines/sha/f5d11a59ad41536be7516b1752dc40213a611a0c' \
  -H 'x-gitlab-version: 17.11.4' \
  -H 'x-requested-with: XMLHttpRequest' \
  --compressed ;
curl $'https://www.eastcomccmp.top/egitlab/api/graphql?query=query%20getPipelineIid(%24fullPath%3A%20ID\u0021%2C%20%24sha%3A%20String\u0021)%20%7B%20project(fullPath%3A%20%24fullPath)%20%7B%20id%20pipeline(sha%3A%20%24sha)%20%7B%20id%20iid%20__typename%20%7D%20__typename%20%7D%20%7D&operationName=getPipelineIid&variables=%7B%22fullPath%22%3A%22root%2Fea-hz-travel%22%2C%22sha%22%3A%22f5d11a59ad41536be7516b1752dc40213a611a0c%22%7D' \
  -H 'Accept-Language: zh-CN,zh;q=0.9' \
  -H 'Connection: keep-alive' \
  -H 'Cookie: _gitlab_session=fe681247e580a7f257fae085b442205b; preferred_language=zh_CN; acw_tc=2760820217524818480614973e49572ed1d7a6978b0f8fc4a373b4865a7355; known_sign_in=eDFabTVEUFNWVjlScG5jQW8zQVJKVnpsaGc2T3lGNWcxMU1HOTVKZ0pEUk1aakE5TVFWcUZNRmN3VXMyS0VlYk1uM3VQU0JhM1NZYUh5bTMyN2tOc0x2MG5HOFV0UHdnY0xlT29WeWRFeGZ0THpKTllNNXF0cm1tUDVUU0lVTVYtLXJNbjlUZ0JobHhSL2kzSld0YjYzd3c9PQ%3D%3D--a8b0a6d41df51d57bd5ac066d722e5adaf29944b; event_filter=all' \
  -H 'If-None-Match: W/"51cd776a653c966241ea7ee2fd61741b"' \
  -H 'Referer: https://www.eastcomccmp.top/egitlab/root/ea-hz-travel/-/ci/editor?branch_name=master' \
  -H 'Sec-Fetch-Dest: empty' \
  -H 'Sec-Fetch-Mode: cors' \
  -H 'Sec-Fetch-Site: same-origin' \
  -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36' \
  -H 'accept: */*' \
  -H 'content-type: application/json' \
  -H 'sec-ch-ua: "Chromium";v="116", "Not)A;Brand";v="24", "Google Chrome";v="116"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'sec-ch-ua-platform: "macOS"' \
  -H 'x-csrf-token: lNOdKs6IZBu9F9c1uAYbvaHZ1lp3TNIO0OtbUt3FvC-jui1v6fVXPH8mMN_CFsO-GNg-m-XoY-ygHEpnB7RpNg' \
  -H 'x-gitlab-feature-category: pipeline_composition' \
  -H 'x-gitlab-graphql-feature-correlation: verify/ci/pipeline-graph' \
  -H 'x-gitlab-graphql-resource-etag: /egitlab/api/graphql:pipelines/sha/f5d11a59ad41536be7516b1752dc40213a611a0c' \
  -H 'x-gitlab-version: 17.11.4' \
  -H 'x-requested-with: XMLHttpRequest' \
  --compressed ;
curl $'https://www.eastcomccmp.top/egitlab/api/graphql?query=query%20getPipelineIid(%24fullPath%3A%20ID\u0021%2C%20%24sha%3A%20String\u0021)%20%7B%20project(fullPath%3A%20%24fullPath)%20%7B%20id%20pipeline(sha%3A%20%24sha)%20%7B%20id%20iid%20__typename%20%7D%20__typename%20%7D%20%7D&operationName=getPipelineIid&variables=%7B%22fullPath%22%3A%22root%2Fea-hz-travel%22%2C%22sha%22%3A%22f5d11a59ad41536be7516b1752dc40213a611a0c%22%7D' \
  -H 'Accept-Language: zh-CN,zh;q=0.9' \
  -H 'Connection: keep-alive' \
  -H 'Cookie: _gitlab_session=fe681247e580a7f257fae085b442205b; preferred_language=zh_CN; acw_tc=2760820217524818480614973e49572ed1d7a6978b0f8fc4a373b4865a7355; known_sign_in=eDFabTVEUFNWVjlScG5jQW8zQVJKVnpsaGc2T3lGNWcxMU1HOTVKZ0pEUk1aakE5TVFWcUZNRmN3VXMyS0VlYk1uM3VQU0JhM1NZYUh5bTMyN2tOc0x2MG5HOFV0UHdnY0xlT29WeWRFeGZ0THpKTllNNXF0cm1tUDVUU0lVTVYtLXJNbjlUZ0JobHhSL2kzSld0YjYzd3c9PQ%3D%3D--a8b0a6d41df51d57bd5ac066d722e5adaf29944b; event_filter=all' \
  -H 'If-None-Match: W/"51cd776a653c966241ea7ee2fd61741b"' \
  -H 'Referer: https://www.eastcomccmp.top/egitlab/root/ea-hz-travel/-/ci/editor?branch_name=master' \
  -H 'Sec-Fetch-Dest: empty' \
  -H 'Sec-Fetch-Mode: cors' \
  -H 'Sec-Fetch-Site: same-origin' \
  -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36' \
  -H 'accept: */*' \
  -H 'content-type: application/json' \
  -H 'sec-ch-ua: "Chromium";v="116", "Not)A;Brand";v="24", "Google Chrome";v="116"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'sec-ch-ua-platform: "macOS"' \
  -H 'x-csrf-token: lNOdKs6IZBu9F9c1uAYbvaHZ1lp3TNIO0OtbUt3FvC-jui1v6fVXPH8mMN_CFsO-GNg-m-XoY-ygHEpnB7RpNg' \
  -H 'x-gitlab-feature-category: pipeline_composition' \
  -H 'x-gitlab-graphql-feature-correlation: verify/ci/pipeline-graph' \
  -H 'x-gitlab-graphql-resource-etag: /egitlab/api/graphql:pipelines/sha/f5d11a59ad41536be7516b1752dc40213a611a0c' \
  -H 'x-gitlab-version: 17.11.4' \
  -H 'x-requested-with: XMLHttpRequest' \
  --compressed ;
curl $'https://www.eastcomccmp.top/egitlab/api/graphql?query=query%20getPipelineIid(%24fullPath%3A%20ID\u0021%2C%20%24sha%3A%20String\u0021)%20%7B%20project(fullPath%3A%20%24fullPath)%20%7B%20id%20pipeline(sha%3A%20%24sha)%20%7B%20id%20iid%20__typename%20%7D%20__typename%20%7D%20%7D&operationName=getPipelineIid&variables=%7B%22fullPath%22%3A%22root%2Fea-hz-travel%22%2C%22sha%22%3A%22f5d11a59ad41536be7516b1752dc40213a611a0c%22%7D' \
  -H 'Accept-Language: zh-CN,zh;q=0.9' \
  -H 'Connection: keep-alive' \
  -H 'Cookie: _gitlab_session=fe681247e580a7f257fae085b442205b; preferred_language=zh_CN; acw_tc=2760820217524818480614973e49572ed1d7a6978b0f8fc4a373b4865a7355; known_sign_in=eDFabTVEUFNWVjlScG5jQW8zQVJKVnpsaGc2T3lGNWcxMU1HOTVKZ0pEUk1aakE5TVFWcUZNRmN3VXMyS0VlYk1uM3VQU0JhM1NZYUh5bTMyN2tOc0x2MG5HOFV0UHdnY0xlT29WeWRFeGZ0THpKTllNNXF0cm1tUDVUU0lVTVYtLXJNbjlUZ0JobHhSL2kzSld0YjYzd3c9PQ%3D%3D--a8b0a6d41df51d57bd5ac066d722e5adaf29944b; event_filter=all' \
  -H 'If-None-Match: W/"51cd776a653c966241ea7ee2fd61741b"' \
  -H 'Referer: https://www.eastcomccmp.top/egitlab/root/ea-hz-travel/-/ci/editor?branch_name=master' \
  -H 'Sec-Fetch-Dest: empty' \
  -H 'Sec-Fetch-Mode: cors' \
  -H 'Sec-Fetch-Site: same-origin' \
  -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36' \
  -H 'accept: */*' \
  -H 'content-type: application/json' \
  -H 'sec-ch-ua: "Chromium";v="116", "Not)A;Brand";v="24", "Google Chrome";v="116"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'sec-ch-ua-platform: "macOS"' \
  -H 'x-csrf-token: lNOdKs6IZBu9F9c1uAYbvaHZ1lp3TNIO0OtbUt3FvC-jui1v6fVXPH8mMN_CFsO-GNg-m-XoY-ygHEpnB7RpNg' \
  -H 'x-gitlab-feature-category: pipeline_composition' \
  -H 'x-gitlab-graphql-feature-correlation: verify/ci/pipeline-graph' \
  -H 'x-gitlab-graphql-resource-etag: /egitlab/api/graphql:pipelines/sha/f5d11a59ad41536be7516b1752dc40213a611a0c' \
  -H 'x-gitlab-version: 17.11.4' \
  -H 'x-requested-with: XMLHttpRequest' \
  --compressed ;
curl $'https://www.eastcomccmp.top/egitlab/api/graphql?query=query%20getPipelineIid(%24fullPath%3A%20ID\u0021%2C%20%24sha%3A%20String\u0021)%20%7B%20project(fullPath%3A%20%24fullPath)%20%7B%20id%20pipeline(sha%3A%20%24sha)%20%7B%20id%20iid%20__typename%20%7D%20__typename%20%7D%20%7D&operationName=getPipelineIid&variables=%7B%22fullPath%22%3A%22root%2Fea-hz-travel%22%2C%22sha%22%3A%22f5d11a59ad41536be7516b1752dc40213a611a0c%22%7D' \
  -H 'Accept-Language: zh-CN,zh;q=0.9' \
  -H 'Connection: keep-alive' \
  -H 'Cookie: _gitlab_session=fe681247e580a7f257fae085b442205b; preferred_language=zh_CN; acw_tc=2760820217524818480614973e49572ed1d7a6978b0f8fc4a373b4865a7355; known_sign_in=eDFabTVEUFNWVjlScG5jQW8zQVJKVnpsaGc2T3lGNWcxMU1HOTVKZ0pEUk1aakE5TVFWcUZNRmN3VXMyS0VlYk1uM3VQU0JhM1NZYUh5bTMyN2tOc0x2MG5HOFV0UHdnY0xlT29WeWRFeGZ0THpKTllNNXF0cm1tUDVUU0lVTVYtLXJNbjlUZ0JobHhSL2kzSld0YjYzd3c9PQ%3D%3D--a8b0a6d41df51d57bd5ac066d722e5adaf29944b; event_filter=all' \
  -H 'If-None-Match: W/"51cd776a653c966241ea7ee2fd61741b"' \
  -H 'Referer: https://www.eastcomccmp.top/egitlab/root/ea-hz-travel/-/ci/editor?branch_name=master' \
  -H 'Sec-Fetch-Dest: empty' \
  -H 'Sec-Fetch-Mode: cors' \
  -H 'Sec-Fetch-Site: same-origin' \
  -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36' \
  -H 'accept: */*' \
  -H 'content-type: application/json' \
  -H 'sec-ch-ua: "Chromium";v="116", "Not)A;Brand";v="24", "Google Chrome";v="116"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'sec-ch-ua-platform: "macOS"' \
  -H 'x-csrf-token: lNOdKs6IZBu9F9c1uAYbvaHZ1lp3TNIO0OtbUt3FvC-jui1v6fVXPH8mMN_CFsO-GNg-m-XoY-ygHEpnB7RpNg' \
  -H 'x-gitlab-feature-category: pipeline_composition' \
  -H 'x-gitlab-graphql-feature-correlation: verify/ci/pipeline-graph' \
  -H 'x-gitlab-graphql-resource-etag: /egitlab/api/graphql:pipelines/sha/f5d11a59ad41536be7516b1752dc40213a611a0c' \
  -H 'x-gitlab-version: 17.11.4' \
  -H 'x-requested-with: XMLHttpRequest' \
  --compressed ;
curl $'https://www.eastcomccmp.top/egitlab/api/graphql?query=query%20getPipelineIid(%24fullPath%3A%20ID\u0021%2C%20%24sha%3A%20String\u0021)%20%7B%20project(fullPath%3A%20%24fullPath)%20%7B%20id%20pipeline(sha%3A%20%24sha)%20%7B%20id%20iid%20__typename%20%7D%20__typename%20%7D%20%7D&operationName=getPipelineIid&variables=%7B%22fullPath%22%3A%22root%2Fea-hz-travel%22%2C%22sha%22%3A%22f5d11a59ad41536be7516b1752dc40213a611a0c%22%7D' \
  -H 'Accept-Language: zh-CN,zh;q=0.9' \
  -H 'Connection: keep-alive' \
  -H 'Cookie: _gitlab_session=fe681247e580a7f257fae085b442205b; preferred_language=zh_CN; acw_tc=2760820217524818480614973e49572ed1d7a6978b0f8fc4a373b4865a7355; known_sign_in=eDFabTVEUFNWVjlScG5jQW8zQVJKVnpsaGc2T3lGNWcxMU1HOTVKZ0pEUk1aakE5TVFWcUZNRmN3VXMyS0VlYk1uM3VQU0JhM1NZYUh5bTMyN2tOc0x2MG5HOFV0UHdnY0xlT29WeWRFeGZ0THpKTllNNXF0cm1tUDVUU0lVTVYtLXJNbjlUZ0JobHhSL2kzSld0YjYzd3c9PQ%3D%3D--a8b0a6d41df51d57bd5ac066d722e5adaf29944b; event_filter=all' \
  -H 'If-None-Match: W/"51cd776a653c966241ea7ee2fd61741b"' \
  -H 'Referer: https://www.eastcomccmp.top/egitlab/root/ea-hz-travel/-/ci/editor?branch_name=master' \
  -H 'Sec-Fetch-Dest: empty' \
  -H 'Sec-Fetch-Mode: cors' \
  -H 'Sec-Fetch-Site: same-origin' \
  -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36' \
  -H 'accept: */*' \
  -H 'content-type: application/json' \
  -H 'sec-ch-ua: "Chromium";v="116", "Not)A;Brand";v="24", "Google Chrome";v="116"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'sec-ch-ua-platform: "macOS"' \
  -H 'x-csrf-token: lNOdKs6IZBu9F9c1uAYbvaHZ1lp3TNIO0OtbUt3FvC-jui1v6fVXPH8mMN_CFsO-GNg-m-XoY-ygHEpnB7RpNg' \
  -H 'x-gitlab-feature-category: pipeline_composition' \
  -H 'x-gitlab-graphql-feature-correlation: verify/ci/pipeline-graph' \
  -H 'x-gitlab-graphql-resource-etag: /egitlab/api/graphql:pipelines/sha/f5d11a59ad41536be7516b1752dc40213a611a0c' \
  -H 'x-gitlab-version: 17.11.4' \
  -H 'x-requested-with: XMLHttpRequest' \
  --compressed ;
curl $'https://www.eastcomccmp.top/egitlab/api/graphql?query=query%20getPipelineIid(%24fullPath%3A%20ID\u0021%2C%20%24sha%3A%20String\u0021)%20%7B%20project(fullPath%3A%20%24fullPath)%20%7B%20id%20pipeline(sha%3A%20%24sha)%20%7B%20id%20iid%20__typename%20%7D%20__typename%20%7D%20%7D&operationName=getPipelineIid&variables=%7B%22fullPath%22%3A%22root%2Fea-hz-travel%22%2C%22sha%22%3A%22f5d11a59ad41536be7516b1752dc40213a611a0c%22%7D' \
  -H 'Accept-Language: zh-CN,zh;q=0.9' \
  -H 'Connection: keep-alive' \
  -H 'Cookie: _gitlab_session=fe681247e580a7f257fae085b442205b; preferred_language=zh_CN; acw_tc=2760820217524818480614973e49572ed1d7a6978b0f8fc4a373b4865a7355; known_sign_in=eDFabTVEUFNWVjlScG5jQW8zQVJKVnpsaGc2T3lGNWcxMU1HOTVKZ0pEUk1aakE5TVFWcUZNRmN3VXMyS0VlYk1uM3VQU0JhM1NZYUh5bTMyN2tOc0x2MG5HOFV0UHdnY0xlT29WeWRFeGZ0THpKTllNNXF0cm1tUDVUU0lVTVYtLXJNbjlUZ0JobHhSL2kzSld0YjYzd3c9PQ%3D%3D--a8b0a6d41df51d57bd5ac066d722e5adaf29944b; event_filter=all' \
  -H 'If-None-Match: W/"51cd776a653c966241ea7ee2fd61741b"' \
  -H 'Referer: https://www.eastcomccmp.top/egitlab/root/ea-hz-travel/-/ci/editor?branch_name=master' \
  -H 'Sec-Fetch-Dest: empty' \
  -H 'Sec-Fetch-Mode: cors' \
  -H 'Sec-Fetch-Site: same-origin' \
  -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36' \
  -H 'accept: */*' \
  -H 'content-type: application/json' \
  -H 'sec-ch-ua: "Chromium";v="116", "Not)A;Brand";v="24", "Google Chrome";v="116"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'sec-ch-ua-platform: "macOS"' \
  -H 'x-csrf-token: lNOdKs6IZBu9F9c1uAYbvaHZ1lp3TNIO0OtbUt3FvC-jui1v6fVXPH8mMN_CFsO-GNg-m-XoY-ygHEpnB7RpNg' \
  -H 'x-gitlab-feature-category: pipeline_composition' \
  -H 'x-gitlab-graphql-feature-correlation: verify/ci/pipeline-graph' \
  -H 'x-gitlab-graphql-resource-etag: /egitlab/api/graphql:pipelines/sha/f5d11a59ad41536be7516b1752dc40213a611a0c' \
  -H 'x-gitlab-version: 17.11.4' \
  -H 'x-requested-with: XMLHttpRequest' \
  --compressed
```
