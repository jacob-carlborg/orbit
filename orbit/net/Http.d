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

import orbit.core._;
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
		// scope page = new HttpGet(url);
		// page.setTimeout(timeout);
		// auto buffer = page.open;
		// 
		// checkPageStatus(page, url);
		// 
		// int contentLength = page.getResponseHeaders.getInt(HttpHeader.ContentLength);
		// int bytesLeft = contentLength;
		// int chunkSize = bytesLeft / 40;
		// 
		// while (bytesLeft > 0)
		// {
		// 	buffer.load(chunkSize > bytesLeft ? bytesLeft : chunkSize);
		// 	bytesLeft -= chunkSize;
		// 	orbit.progress(bytesLeft, contentLength, chunkSize);
		// }
		// 
		// return buffer.slice;
		
		auto page = new HttpGet(url);
		page.setTimeout(30f);
		auto buffer = page.open;
		
		scope(exit)
			page.close;
		
		checkPageStatus(page, url);

		// load in chunks in order to display progress
		int contentLength = page.getResponseHeaders.getInt(HttpHeader.ContentLength);

		enum int width = 40;
		int num = width;

		version (Posix)
		{
			const clearLine = "\033[1K"; // clear backwards
			const saveCursor = "\0337";
			const restoreCursor = "\0338";
		}
		
		else
		{
			const clearLine = "\r";
			
			// Leaving these empty string causes a linker error:
			// http://d.puremagic.com/issues/show_bug.cgi?id=4315
			const saveCursor = "\0";
			const restoreCursor = "\0";
		}
		
		print(saveCursor);

		int bytesLeft = contentLength;
		int chunkSize = bytesLeft / num;
		
		while (bytesLeft > 0)
		{
			buffer.load(chunkSize > bytesLeft ? bytesLeft : chunkSize);
			bytesLeft -= chunkSize;
			int i = 0;
			
			print(clearLine ~ restoreCursor ~ saveCursor);
			print("[");
			
			for ( ; i < (width - num); i++)
				print("=");

			print('>');
			
			for ( ; i < width; i++) 
				print(" ");
			
			print("]");
			print(" ", (contentLength - bytesLeft) / 1024, "/", contentLength / 1024, " KB");
			
			num--;
		}
			
		println(restoreCursor);
		println();

		return buffer.slice;
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