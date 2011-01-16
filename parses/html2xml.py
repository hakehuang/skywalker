#!/usr/bin/env python

import sys
import os
import getopt
import urllib
from HTMLParser import HTMLParser

attribute_list = ['NULL','MODULE_TITLE','TITLE','CONTENT','RETURN']

module_dic = {'strong':'MODULE_TITLE',
               'p':'CONTENT',
							 'br':'RETURN',
							 'a':'TITLE',
}

case_dic = {'td':'CONENT',
            'br':'RETURN',
						'parent':module_dic
}

subcase_dic = {'td':'CONTENT',
               'br':'RETURN',
							 'parent':case_dic
}

top_dic = {'html':module_dic,
           'table':case_dic,	
	         'tr':subcase_dic
}

class MyHTMLParser(HTMLParser):
		def reset(self):
			HTMLParser.reset(self)
			self._level_stack = []
			self.cur_dic = module_dic
			self.cur_attr = 'NULL'
			self.cur_content = ''
			self.file_name = 'UNKNOWN'
			self.module_des = 0
		def handle_starttag(self, tag, attrs):
			#print "Encountered the beginning of a %s" % tag
			for k, v in top_dic.iteritems():
				if (k == tag):
					self.cur_dic = v
					self.cur_attr = 'NULL'
					return
				else:
					pass
			for k,v in self.cur_dic.iteritems():
				if (k == tag):
					self.cur_attr = v
				else:
					pass
			if (self.cur_attr == 'RETURN'):
				self.cur_content += '\n'
			else:
				pass
		def handle_endtag(self, tag):
			#print "Encountered the end of a %s tag" % tag
			if (self.cur_attr == 'CONTENT' and len(self.cur_content)):
				print self.cur_content
			elif (self.cur_attr == 'RETURN'):
				pass
			elif (self.cur_attr == 'MODULE_TITLE' and len(self.file_name)):
				print self.file_name
			elif (self.cur_attr == 'TITLE' and len(self.cur_content)):
				if(self.module_des == 0):
					self.module_des = 1
				else:
					print "<<<start>>>"
				print self.cur_content
			else:
				pass
			if (self.cur_dic.has_key(tag)):
				if (self.cur_dic[tag] == self.cur_attr):
					if (self.cur_attr != 'RETURN'):
						self.cur_attr = 'NULL'
						self.cur_content = ''
					else:
						pass
				else:
					pass
			else:
				pass
			if (top_dic.has_key(tag)):
				if (top_dic[tag] == self.cur_dic and self.cur_dic.has_key('parent')):
					self.cur_dic = self.cur_dic['parent']
					self.cur_attr = 'NULL'
					if (len(self.cur_content)):
						print self.cur_content
						self.cur_content = ''
					else:
						pass
					if (self.cur_dic == module_dic):
						print "<<<end>>>"
					else:
						pass
				else:
					pass
			else:
				pass
		def handle_data(self, data):
			if (self.cur_attr == 'CONTENT' or self.cur_attr == 'TITLE' or self.cur_attr == 'RETURN'):
				self.cur_content += data
			elif (self.cur_attr == 'MODULE_TITLE'):
				self.file_name = data
			else:
				pass

def usage():
        print "-h: this help"
 
try:
    opts, args = getopt.getopt(sys.argv[1:], "h",\
        ["help"])
except getopt.error, msg:
        print msg
        print "for help use --help"
        sys.exit(2)


for filename in args:
	content = unicode(urllib.urlopen(filename).read(), 'UTF8')
	parser = MyHTMLParser()
	parser.feed(content)
	parser.close()
