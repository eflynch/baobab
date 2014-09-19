from xml.etree.ElementTree import parse
import json
import random

tree = parse('mammalia.xml')
root = tree.getroot().find('NODE')

def parseTree(root):
	value = ''
	subtrees = []
	for child in root:
		if child.tag == 'NAME':
			value = child.text or ''
		if child.tag == 'NODES':
			for subNode in child:
				subtrees.append(parseTree(subNode))

	identifier = random.randint(0, 100000)
	return {'value': value, 'subtrees': subtrees, 'id': identifier, 'collapsed': False, 'type': 'rectangle'}


print json.dumps(parseTree(root))
