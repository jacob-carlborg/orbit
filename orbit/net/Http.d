/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Dec 16, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module orbit.net.Http;

import tango.core.Exception;
import tango.io.device.File;
import tango.io.model.IConduit;
import tango.net.device.Socket;
import tango.net.http.HttpGet;
import tango.net.http.HttpConst;

import mambo.core._;
import orbit.orbit.Orbit;

struct Http
{

static:

	void download (string url, string destination, float timeout = 30f, Orbit orbit = Orbit.defaultOrbit)
	{
		auto data = download(url, timeout, orbit);
		writeFile(data, destination);
	}

	void[] download (string url, float timeout = 30f, Orbit orbit = Orbit.defaultOrbit)
	{
		scope page = new HttpGet(url);
		page.setTimeout(timeout);
		auto buffer = page.open;
		
		checkPageStatus(page, url);

		auto contentLength = page.getResponseHeaders.getInt(HttpHeader.ContentLength);

		enum width = 40;
		int bytesLeft = contentLength;
		int chunkSize = bytesLeft / width;
		
		orbit.progress.start(contentLength, chunkSize, width);
		
		while (bytesLeft > 0)
		{
			buffer.load(chunkSize > bytesLeft ? bytesLeft : chunkSize);
			bytesLeft -= chunkSize;
			orbit.progress(bytesLeft);
		}
		
		orbit.progress.end();

		return buffer.slice;
	}
	
	void upload (T) (string url, T[] content, float timeout = 30f, Orbit orbit = Orbit.defaultOrbit)
	{
		scope page = new HttpPost(url);
		page.setTimeout(timeout);
		auto buffer = page.open;
		
		checkPageStatus(page, url);
		
		enum width = 40;
		int bytesLeft = content.length * T.sizeof;
		int chunkSize = bytesLeft / width;
		
		orbit.progress.start(bytesLeft, chunkSize, width);
		
		while (bytesLeft > 0)
		{
			auto chunk = chunkSize > bytesLeft ? bytesLeft : chunkSize;
			bytesLeft -= buffer.write(content[0 .. chunk / T.sizeof]);
			orbit.progress(bytesLeft);
		}
		
		orbit.progress.end();
	}
	
	bool exists (string url)
	{
		scope resource = new HttpGet(url);
		resource.open;
		
		return resource.isResponseOK;
	}
	
private:
	
	void checkPageStatus (HttpGet page, string url)
	{
		if (page.getStatus == 404)
			throw new IOException(format(`The resource with URL "{}" could not be found.`, url));
		
		else if (!page.isResponseOK)
			throw new IOException(format(`An unexpected error occurred. The resource "{}" responded with the message "{}" and the status code {}.`, url, page.getResponse.getReason, page.getResponse.getStatus));
	}
	
	void writeFile (void[] data, string filename)
	{
		scope file = new File(filename, File.WriteCreate);
		file.write(data);
	}
}