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
                elif str(child.attrib['Name']) == "DstBlock":
                    dst = str(child.text)
                    #if edge:
                    g.add_edge(src,dst,label=str(edge),color='blue')
                        #edge = ''
                        #else:
                        #g.add_edge(src,dst,label=str(src+dst),color='blue')

            if child.tag == 'Branch':
                for gchild in child:
                    #print('****'+str(gchild.attrib['Name']))
                        if gchild.tag == 'P' and str(gchild.attrib['Name']) == "DstBlock":
                            dst = str(gchild.text)
                            #if edge:
                            g.add_edge(src,dst,label=str(edge),color='blue')
                                #edge =''
                                #else:
                                #g.add_edge(src,dst,label=str(src+dst),color='blue')
                        elif gchild.tag == 'Branch':
                            for ggchild in gchild:
                                if ggchild.tag == 'P' and str(ggchild.attrib['Name']) == "DstBlock":
                                    dst = str(ggchild.text)
                                    #if edge:
                                    g.add_edge(src,dst,label=str(edge),color='blue')
                                        #edge = ''
                                        #else:
                                        #g.add_edge(src,dst,label=str(src+dst),color='blue')
                                elif ggchild.tag == 'Branch':
                                    for gggchild in ggchild:
                                        if gggchild.tag == 'P' and str(gggchild.attrib['Name']) == "DstBlock":
                                            dst = str(gggchild.text)
                                            #if edge:
                                            g.add_edge(src,dst,label=str(edge),color='blue')
                                                #edge = ''
                                                #else:
                                                #g.add_edge(src,dst,label=str(src+dst),color='blue')
		#print(src),
		#print(dst)

def display(g,name):
    #print('****************** edge connections *************************') 
    #print("number of blocks is "),
    #print(g.number_of_nodes())
    #print(list(g.nodes))
    #print(list(g.edges))
    #print(g.edges.data('label'))
    #print('****************** connections *************************') 
    #print(list(nx.connected_components(g)))
    #pos = nx.nx_agraph.graphviz_layout(g)
    #plt.subplot(121)
    #nx.draw(g,node_color = 'red', pos=pos,with_labels=True)
    #plt.show()
    #plt.savefig(name+'.png')
    write_dot(g, name+'.dot')
    # the above command generates a dot file which we can convert to 
    #a dependency graph using command dot -Tps graph.dot -o  graph.ps
	
	#T = nx.dfs_tree(G, source=0)
	#list(T.edges())
    #A = nx.adjacency_matrix(g)
	#print(A.todense())
	#T=A.todense()
	#for line in nx.generate_adjlist(g):
	#	print(line)
	#nx.convert_node_labels_to_integers(g)	



def parseXML(xmlfile,errSig): 

    tree = ET.parse(xmlfile) 

    root = tree.getroot() 
    items = [] 
    #g = nx.DiGraph()
    g = nx.MultiDiGraph()
    loc = './Model/System'
    addnode(root,loc,g)
			
			
    #i = 0 # this is for mapping nodes to adj matrix 
    loc = loc + '/Line'	
    addedge(root,loc,g)	
    display(g,"main")    
			
    #sub=src_dst(g,errSig)
    #print(sub)
    # TODO: now we need to think of exploring subsystems recursively
   
    '''	
    loc = './Model/System'
    for item in root.findall(loc): 
        for child in item:
            if child.tag == 'Block' and str(child.attrib['BlockType']) == "SubSystem" and str(child.attrib['Name']) == str(sub):
                #print(str(child.attrib['Name']))
                loc = './System'	
                addnode(child,loc,gsub)
                loc = loc + '/Line'	
                addedge(child,loc,gsub)	
    '''
    #display(gsub,"sub")    

			
    #print("#####################")
    #errSig=str(input())
    #print(errSig)
    g_rev=nx.DiGraph.reverse(g)
    reachable_edges(g_rev,errSig)
	
    #list(T.edges())	
    return




def src_dst(g,edge):
    for u,v,a in g.edges(data=True):
        if a['label'] == edge: 
            src = v
            dst = u 
            break
    return src
    #return [src,dst]	 


def reachable_edges(g,edge):
    sslice = []
    eslice = []
	#g.in_edges(node)
	#g.out_edges(node)
    #print(edge)
    for u,v,a in g.edges(data=True):
        #print(u)
        #print(v)
        #print(a['label'])
        if str(a['label']) == str(edge): 
            src = v
            dst = u
            break	 
		
    #print("src ")
    #print(src)
    q = queue.Queue(maxsize=20)        
    for node in g.nodes:
        if node == src:
            if not sslice or node not in sslice:
                sslice.append(node)
                for item in g[node]:
                    q.put(item)
                    for index in range(g.number_of_edges(node,item)): 
                        edge = g.get_edge_data(node,item,index)
                        #print(edge)
                        eslice.append(edge['label'])
                    #print("first ")
                    #print(item)
                    sslice.append(item)

    while not q.empty():
        node = q.get()
        for item in g[node]:
            edge = g.get_edge_data(node,item)
            if edge not in eslice:
                if item not in sslice:
                    q.put(item)
                for index in range(g.number_of_edges(node,item)): 
                    edge = g.get_edge_data(node,item,index)
                    #print(edge)
                    eslice.append(edge['label'])
                #print("second ")
                #print(item)
                sslice.append(item)
		
    eslice = list(set(eslice))
    #print("slice contains ")
    print(eslice)
    return

	
def main(): 

    # parse xml file 
    #items = parseXML('sldemo_autotrans_myModel.xml') 
    xmlfile = sys.argv[1]
    #errSig = sys.argv[2]
    #print(str(xmlfile))
    parseXML(xmlfile,str(sys.argv[2])) 
	
	
if __name__ == "__main__": 

    # calling main function 
    main() 

