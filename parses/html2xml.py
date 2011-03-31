#!/usr/bin/env python
#
#convert html case to xml docboot format
#usage 
# for i in $(ls /home/shared/test_case_release/module_*.html); do ./html2xml.py $i ; done

import sys
import os
import getopt
import urllib
import string

from types import *
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

output_file_head = [
'<?xml version="1.0" encoding="UTF-8"?>', 
'<?xml-stylesheet type="text/xsl" href="testcase.xsl"?>'
]

void_dic = {
'0':'NULL'	
}

formalpara_dic = {
'0':['<formalpara>'],
'1':['<title>','CONTENT','</title>\n'],
'2':['<para>','CONTENT','</para>\n'],
'end':['</formalpara>'],
'cnt':3,
'parent':void_dic
}

screen_dic = {
'0':['<screen>'],
'1':['<![CDATA[','CONTENT',']]>'],
'end':['</screen>\n'],
'cnt':2,
'parent':void_dic
}

formalpara2_dic = {
'0':['<formalpara>'],
'1':['<title>','CONTENT','</title>\n'],
'2':screen_dic,
'end':['</formalpara>\n'],
'cnt':3,
'parent':void_dic
}

output_case_dic = {
'0':['<sect1 ','id=','>'],
'1':['<title>','CONTENT','</title>\n'],
'2':formalpara_dic,#name
'3':formalpara_dic,#Category
'4':formalpara_dic,#Auto level
'5':formalpara_dic,#Objective
'6':formalpara_dic,#Environment
'7':formalpara2_dic,#Steps
'8':formalpara_dic,#Expected Result
'9':formalpara2_dic,#Command Line
'end':['</sect1>\n'],
'cnt':10,
'parent': void_dic
}

output_top_dic = {
'0':['<chapter ','name=','>'],
'1':['<title>','CONTENT','</title>\n'],
'2':['<sect>','CONTENT','</sect>\n'],
'3':output_case_dic,
'*':'3',
'end':['</chapter>'],
'cnt':-1
}

class MyHTMLParser(HTMLParser):
		def close(self):
			if (len(self.output_tree)):
				output_top_dic['cnt'] = self.output_tree[0]
				while (self.output != output_top_dic ):
					self.cur_content = ""
					self.xmlprint()
			print output_top_dic['end'][0]
			self.of.write(output_top_dic['end'][0])
			if(self.file_name != 'UNKNOWN'):
				self.of.close()
		def reset(self):
			HTMLParser.reset(self)
			self._level_stack = []
			self.cur_dic = module_dic
			self.cur_attr = 'NULL'
			self.old_attr = 'NULL'
			self.cur_content = ''
			self.file_name = 'UNKNOWN'
			self.module_des = 0
			self.output = output_top_dic
			self.output_cnt = 0
			self.output_list_cnt = 0
			self.output_tree = []
			self.case_title = ''
			self.of = 'NULL'
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
					if (self.cur_attr != 'RETURN'):
						self.old_attr = self.cur_attr
					else:
						pass
					self.cur_attr = v
				else:
					pass
			if (self.cur_attr == 'RETURN'):
				self.cur_content += '\n'
			else:
				pass
		def handle_endtag(self, tag):
			#print "Encountered the end of a %s tag" % tag
			#print self.cur_content
			if (self.cur_attr == 'CONTENT'):
				##print self.cur_content
				self.xmlprint()
			elif (self.cur_attr == 'RETURN'):
				self.cur_attr = self.old_attr;
				pass
			elif (self.cur_attr == 'MODULE_TITLE'):
				##print self.file_name
				self.xmlprint()
			elif (self.cur_attr == 'TITLE'):
				if(self.module_des == 0):
					self.module_des = 1
				else:
					pass
					#print "<<<start>>>"
				##print self.cur_content
				self.xmlprint()
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
						self.xmlprint()
						self.cur_content = ''
					else:
						pass
					if (self.cur_dic == module_dic):
						pass
						#print "<<<end>>>"
					else:
						pass
				else:
					pass
			else:
				pass
		def handle_data(self, data):
			#print '++++++'+data
			if (self.cur_attr == 'CONTENT' or self.cur_attr == 'TITLE' or self.cur_attr == 'RETURN'):
				self.cur_content += data
			elif (self.cur_attr == 'MODULE_TITLE'):
				self.file_name = data.replace(" ","_").replace("/","_")
				print self.file_name
			else:
				pass
		def xmlprint(self):
			if (self.file_name == 'UNKNOWN'):
				return
			elif (self.of == 'NULL'):
				self.of = file(self.file_name + "_L.xml",'w')
				if (self.output == output_top_dic and self.output_cnt ==0 and self.output_list_cnt == 0):
					print output_file_head[0]
					self.of.write(output_file_head[0] + "\n")
					print output_file_head[1]
					self.of.write(output_file_head[1] + "\n")
				else:
					pass
			else:
				pass
			self.cur_content = self.cur_content.lstrip()
			if (self.output == output_top_dic and self.output_cnt > 2):
				if(len(self.cur_content) == 0):
					return
				else:
					pass
			else:
				pass
			if(self.output.has_key(str(self.output_cnt))):
				mdata = self.output[str(self.output_cnt)]
				if (type(mdata) is ListType):
					#print mdata
					if (self.output_list_cnt < len(mdata)):
						if (mdata[self.output_list_cnt] == 'CONTENT'):
							if (self.output == output_top_dic and self.output_cnt == 0):
								print self.file_name
								self.of.write(self.file_name)
							else:
								if (self.output == output_case_dic and self.output_cnt == 1):
									print self.case_title
									self.of.write(self.case_title)
								else:
									print self.cur_content
									self.of.write(self.cur_content + "\n")
							self.output_list_cnt += 1
							return
						elif (mdata[self.output_list_cnt].find('=') != -1 ):
							if (self.output == output_top_dic and self.output_cnt ==0):
									print "%s\"%s_L\"" %(mdata[self.output_list_cnt],self.file_name)
									self.of.write(mdata[self.output_list_cnt] + "\"" + self.file_name + "_L\"")
							else:
								if (self.output == output_case_dic and self.output_cnt ==0):
									tdata = self.cur_content.split(':')[0]
									print "%s\"%s\"" %(mdata[self.output_list_cnt],tdata)
									self.of.write(mdata[self.output_list_cnt] + "\"" + tdata + "\"")
									self.case_title = self.cur_content
								else:
									print "%s\"%s\"" %(mdata[self.output_list_cnt],self.cur_content)
									self.of.write(mdata[self.output_list_cnt] + "\"" + self.cur_content + "\"")
							self.output_list_cnt += 1
							return
						else:
							print mdata[self.output_list_cnt]
							self.of.write(mdata[self.output_list_cnt])
							self.output_list_cnt += 1
							self.xmlprint()
							return
					else:
						self.output_list_cnt = 0
						self.output_cnt += 1
						self.xmlprint()
						return
				elif (type(mdata) is DictType):
					#print self.output
					mdata['parent'] = self.output
					self.output = mdata
					self.output_tree.append(self.output_cnt)
					self.output_cnt = 0
					self.output_list_cnt = 0
					self.xmlprint()
					return
				else:
					print "should not be here"
					return
			else:
				if (type(self.output) is DictType):
					if (self.output_cnt == self.output['cnt']):
						if (self.output['end']):
							print self.output['end'][0]
							self.of.write(self.output['end'][0])
						else:
							pass
						if (len(self.output_tree)):
							self.output_cnt = self.output_tree.pop()
						else:
							self.output_cnt = 0
						self.output_list_cnt = 0
						if (self.output.has_key('parent')):
							self.output = self.output['parent']
							self.output_cnt += 1
						else:
							pass
						self.xmlprint()
						return
					else:
						if (self.output['cnt'] == -1):
							self.output_cnt = int(self.output['*'][0])
							self.output_list_cnt = 0
							self.xmlprint()
							return
						else:
							return
				else:
					print "should not be here"
					return

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
	try:
		parser.feed(content)
	except:
		parser.close()
		del parser
		sys.exit()
	parser.close()
	del parser
