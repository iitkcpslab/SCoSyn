#Python code to illustrate parsing of XML files 
# importing the required modules 
import xml.etree.ElementTree as ET 
import networkx as nx
import matplotlib.pyplot as plt
from networkx.drawing.nx_pydot import write_dot
import sys
from networkx.drawing.nx_agraph import graphviz_layout
try: 
    import queue
except ImportError:
    import Queue as queue
image = None

def parseXML(xmlfile,errSig): 

    tree = ET.parse(xmlfile) 

    root = tree.getroot() 
    items = [] 
    g = nx.DiGraph()

    for item in root.findall('./Model/System'):                         
        for child in item:          
            if child.tag == 'Block' and str(child.attrib['Name']) == "Model_1":                            
                croot=child
                break

    loc = './Model/System'
	
    for item in root.findall(loc): 
        for child in item:
            if child.tag == 'Block': 
                #print(str(child.attrib['Name']))
                g.add_node(child.attrib['Name'],color='red',style='filled',fillcolor='red')
			
    src = dst = edge = ''
    i = 0 # this is for mapping nodes to adj matrix 
    loc = loc + '/Line'	
    for item in root.findall(loc):
        for child in item: 
            if child.tag == 'P':
                if str(child.attrib['Name']) == "Name":
                    edge = str(child.text)
				
                elif str(child.attrib['Name']) == "SrcBlock":
                    #print(str(child.attrib['Name']))
                    #print(str(child.text))
                    src = str(child.text)
		    #print(str(child[0]))
                elif str(child.attrib['Name']) == "DstBlock":
                    dst = str(child.text)
                    if edge:
                        g.add_edge(src,dst,label=str(edge),color='blue')
                        edge = src = dst = ''
            if child.tag == 'Branch':
                for gchild in child:
                    #print('****'+str(gchild.attrib['Name']))
                        if gchild.tag == 'P' and str(gchild.attrib['Name']) == "DstBlock" and edge:
                            dst = str(gchild.text)
                            g.add_edge(src,dst,label=str(edge),color='blue')
                        elif gchild.tag == 'Branch':
                            for ggchild in gchild:
                                if ggchild.tag == 'P' and str(ggchild.attrib['Name']) == "DstBlock":
                                    dst = str(ggchild.text)
                                    g.add_edge(src,dst,label=str(edge),color='blue')
    A = nx.adjacency_matrix(g)
    #print(errSig)
    g_rev=nx.DiGraph.reverse(g)
    src_dst(g_rev,errSig)
	
    #list(T.edges())	
    return

def src_dst(g,edge):
    src=[]
    dst=[]
    for u,v,a in g.edges(data=True):
        if a['label'] == edge: 
            if v not in src:
                src.append(v)
            if u not in dst:
                dst.append(u) 
    print(src)
    #print(",")
    #print(dst)
    return src 

	
def main(): 

    # parse xml file 
    #items = parseXML('sldemo_autotrans_myModel.xml') 
    xmlfile = sys.argv[1]
    #errSig = sys.argv[2]
    #print(str(xmlfile))
    parseXML(xmlfile,sys.argv[2]) 
	
	
if __name__ == "__main__": 

    # calling main function 
    main() 

