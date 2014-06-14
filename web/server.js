var http = require("http");
var url = require("url");

function start() {
	function onRequest(request, response) {
		var pathname = url.parse(request.url).pathname;
		var returnModule = require("./returnNmodule");
		//console.log("Request for " + pathname + " received." + returnModule.re);
		//console.log("Request for " + pathname + " received." + returnModule.re);
		
		if (pathname.substring(0, 2) == "/c") {
			var id = pathname.substring(2);
			console.log("in connection: " + id);
			var fs = require('fs');
			fs.readFile('./config/' + id, function (err, html) {
				if (err) {
					response.writeHeader(200, {"Content-Type": "text/html"});  
					response.write("failed");  
					response.end();
				}
				else {
					response.writeHeader(200, {"Content-Type": "text/html"});  
					response.write(html);
					response.end();
				}
			});
		}
		else if (pathname.substring(0, 2) == "/u") {
			var id = pathname.substring(2);
			console.log("in upload: " + id);
			var body = "";
			request.on('data', function (chunk) {
				body += chunk;
				//console.log(chunk);
				//console.log(body);
			});
			request.on('end', function () {
				//console.log('POSTed: ' + body);
				//console.log(body);
				response.writeHead(200);
				response.end("okdes");
				var fs = require('fs');
				fs.writeFile("./upload/" + id, body, function(err) {
					if(err) {
						console.log(err);
					} else {
						console.log("The file was saved!");
					}
				}); 
			});
		}
		else {
			response.writeHead(200, {"Content-Type": "text/plain"});
			response.write("text/plain: the default page");
			response.end();
		}
	}

	http.createServer(onRequest).listen(8888);
	console.log("Server has started.");
}

exports.start = start;
