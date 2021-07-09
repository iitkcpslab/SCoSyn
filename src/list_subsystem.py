#Python code to illustrate parsing of XML files 
# importing the required modules 
import xml.etree.ElementTree as ET 
import networkx as nx
import matplotlib.pyplot as plt
from networkx.drawing.nx_pydot import write_dot
import sys
from random import randint
from networkx.drawing.nx_agraph import graphviz_layout
try: 
    import queue
except ImportError:
    import Queue as queue
image = None
                
subsystem = []
atomic = []
masked = []

def addnode(root,loc,g): 
    #print("*****************list of vertices *********************")
    for item in root.findall(loc): 
        for child in item:
            if child.tag == 'Block': 
                #print(str(child.attrib['Name']))
                g.add_node(child.attrib['Name'],color='red',style='filled',fillcolor='red')
				#print(g.vertList)
				#data[child.tag] = child.text.encode('utf8')
				#print(child.attrib['Name']) 
				#if str(child.attrib['BlockType']) == "SubSystem":

def addedge(root,loc,g):
    src = dst = edge = ''
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
                        edge = ''
                    else:
                        g.add_edge(src,dst,label=str(src+dst),color='blue')

            if child.tag == 'Branch':
                for gchild in child:
                    #print('****'+str(gchild.attrib['Name']))
                        if gchild.tag == 'P' and str(gchild.attrib['Name']) == "DstBlock":
                            dst = str(gchild.text)
                            if edge:
                                g.add_edge(src,dst,label=str(edge),color='blue')
                                edge =''
                            else:
                                g.add_edge(src,dst,label=str(src+dst),color='blue')
                        elif gchild.tag == 'Branch':
                            for ggchild in gchild:
                                if ggchild.tag == 'P' and str(ggchild.attrib['Name']) == "DstBlock":
                                    dst = str(ggchild.text)
                                    if edge:
                                        g.add_edge(src,dst,label=str(edge),color='blue')
                                        edge = ''
                                    else:
                                        g.add_edge(src,dst,label=str(src+dst),color='blue')
		#print(src),
		#print(dst)

def explore_subsystem(root,loc,g,suffix):
    for item in root.findall(loc): 
        for child in item:
            if child.tag == 'Block' and str(child.attrib['BlockType']) == "SubSystem":
                #gsub.remove_node(child.attrib['Name'])
                #print(str(child.attrib['Name']))
                loc = './System'	
                addnode(child,loc,g)
                loc = loc + '/Line'	
                addedge(child,loc,g)
                #subsystem.append(str(child.attrib['Name']))
                loc = './System'	
                for gchild in child:
                    if gchild.tag == 'P' and str(gchild.attrib['Name']) == "TreatAsAtomicUnit" and str(gchild.text) == "on":
                        atomic.append(suffix+"/"+str(child.attrib['Name']))
                    elif gchild.tag == 'P' and str(gchild.attrib['Name']) =="ShowPortLabels" and str(gchild.text) == "none":
                        masked.append(suffix+"/"+str(child.attrib['Name']))
                    else:
                        subsystem.append(suffix+"/"+str(child.attrib['Name']))
                explore_subsystem(child,loc,g,str(child.attrib['Name']))


def list_subsystems(xmlfile):
    tree = ET.parse(xmlfile) 

    root = tree.getroot() 
    items = [] 
    g = nx.DiGraph()

    loc = './Model/System'
    for item in root.findall(loc): 
        for child in item:
            if child.tag == 'Block' and str(child.attrib['BlockType']) == "SubSystem":
                #print(str(child.attrib['Name']))
                loc = './System'	
                addnode(child,loc,g)
                loc = loc + '/Line'	
                addedge(child,loc,g)	
                loc = './System'	
                for gchild in child:
                    if gchild.tag == 'P' and str(gchild.attrib['Name']) == "TreatAsAtomicUnit" and str(gchild.text) == "on":
                        atomic.append(str(child.attrib['Name']))
                        break
                    elif (gchild.tag == 'P' and str(gchild.attrib['Name']) =="ShowPortLabels" and str(gchild.text) == "none") or (gchild.tag == 'Object' and str(gchild.attrib['PropName']) =="MaskObject"):
                        masked.append(str(child.attrib['Name']))
                        break
                    else:
                        subsystem.append(str(child.attrib['Name']))
                suffix = str(child.attrib['Name'])
                explore_subsystem(child,loc,g,suffix)
 
    return subsystem,atomic,masked 


	
def main(): 

    # parse xml file 
    #items = parseXML('sldemo_autotrans_myModel.xml') 
    xmlfile = sys.argv[1]
    #errSig = sys.argv[2]
    #print(str(xmlfile))
    #parseXML(xmlfile,sys.argv[2]) 
    lsub,asub,msub=list_subsystems(xmlfile)
    if sys.argv[2] == "all":
        print(list(set(lsub)))
    elif sys.argv[2] == "atomic":
        print(list(set(asub)))
    elif sys.argv[2] == "masked":
        print(list(set(msub)))
	
	
if __name__ == "__main__": 

    # calling main function 
    main() 

