# chattojson
============
This is a demonstration of a task that for a given string needs to be parsed into a JSON formatted string. The string is typically generated from a chat messaging client e.g. Hipchat. For simplicity only three items needs to be parsed.

* mentions: A way to mention a user. Always starts with an '@' and ends when hitting a non-word character. (http://help.hipchat.com/knowledgebase/articles/64429-how-do-mentions-work-)
* emoticons: 'custom' emoticons which are alphanumeric strings, no longer than 15 characters, contained in parenthesis. You can assume that anything matching this format is an emoticon. (https://www.hipchat.com/emoticons)
* links: Any URLs contained in the message, along with the page's title.
* 

# Dependencies
There is no dependencies for the main project to run. However, for unittests there is a dependency on the module 'OHHTTPStubs'.

# Running Tests:
To run the tests first simply run:

		pod install

Then the tests can be run through xcode or xctool.

# Libs:
### Chain:
A lightweight promise like library. It heavily uses GCD for running tasks and for maintaining exclusivity of shared resources. Common use cases can be found in the relevant test cases inside the MSGToJSONTransformerTests folder.

### JSONObject
An abstract class that can be used to hold json object and that can generated dictionary representation of the json object. Internally it uses runtime methods for holding json properties. Common use cases can be found in the test cases inside MSGToJSONTransformerTests.


# How it works:
First thing here is to notice that there exsits an element of asynchronous action. Secondly, there is a dependency graph exists for various tasks. The library Chain, actually is written for tackling these two main issues.

The main task is to convert a text msg into a parsed JSON string by applying some rules. This tasks can be divided into some subtasks and these can be divided into some more.
* Task of detecting URLs in the text.
* Task for getting title of the URL. For every URL there is this task.
	* Task to get the content of the URL
	* Task to parse the content to get the title
*	Task of detecting mentions
*	Task of detecting emoticons
*	
All the above tasks are performed in the class TextToJSONObjectTransformerTask. It utilizes other tasks like FetchHTMLPageContentTask, ParseHTMLPageTask, URLDetectionTask etc. and also some composite of tasks. It is to show that the Chain library can be used to define tasks in various ways. In this example, there are two ways the tasks are definded.
*	Implementing a protocol called TaskProvider.
*	Composite of tasks inside a static container.

There are many greate benifits of doing things like this.
*	light View Controller. 
*	modularity.
*	extensibility.
*	brevity of code structure.

# Improvements:
*	Chain and JSONObject should be in seperate pods.
*	Chain now exectutes all the tasks inside one concurrent queue. There should be an interface for providing user defined queue to run tasks.
*	Currently one specific test case fails for a text having urls placed without spaces. In order to solve that we may have to use regex or NSScanner.
*	To get the title of the URL the full content of the page is fetched. Since most of the time the title exists in the begining of the file we can fetch content in multipart mode and dynamically perform parsing in the content. HOwever, it may not worth as it adds complexity. Also we need to insvestigate whether it really improves the bandwidth use or not.

