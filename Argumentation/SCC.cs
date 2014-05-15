using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Parser
{
    public class Node
    {
        public String id { get; set; }
        public int index { get; set; }
        public int lowlink { get; set; }

        public Node(){ }

        public Node(String id)
        {
            this.id = id;
            this.index = -1;
            this.lowlink = -1;
        }
    }

    public class Graph
    {
        public HashSet<HashSet<Node>> nodes {get; set;}
        public HashSet<Tuple<HashSet<Node>,HashSet<Node>>> edges {get; set;}

        public Graph(HashSet<HashSet<Node>> nodes, HashSet<Tuple<HashSet<Node>, HashSet<Node>>> edges)
        {
            this.nodes = nodes;
            this.edges = edges;
        }
    }

    class SCC
    {
        public static int index = 0;
        public static Stack<Node> S = new Stack<Node>();
        public static HashSet<Tuple<String, String>> edges = new HashSet<Tuple<string, string>>();
        public static Dictionary<String,Node> nodes = new Dictionary<String,Node>();
        public static HashSet<HashSet<Node>> nodesC = new HashSet<HashSet<Node>>();
        public static HashSet<Tuple<HashSet<Node>, HashSet<Node>>> edgesC = new HashSet<Tuple<HashSet<Node>, HashSet<Node>>>();

        public static Graph generateComponentGraph(Dictionary<String, HashSet<Tuple<String,String>>> depGraph)
        {
            var vertices = depGraph.Keys.ToArray();
            var hashEdges = depGraph.Values.ToArray();


            foreach( var vertex in vertices) 
            {
                Node node = new Node(vertex);
                nodes.Add(node.id,node);                
            }

            foreach (var edge in hashEdges)
            {
                edges.UnionWith(edge);
            }

            foreach (Node node in nodes.Values.ToArray())
            {
                if (node.index < 0)
                {
                    HashSet<Node> component = new HashSet<Node>();
                    component = strongconnect(node);
                    nodesC.Add(component);
                }
            }
            foreach (var component1 in nodesC)
            {
                foreach (var component2 in nodesC)
                {
                    bool edgeFound = false;
                    if (component1 != component2)
                    {
                        foreach (var node1 in component1)
                        {
                            foreach (var node2 in component2)
                            {
                                if (edges.Contains(Tuple.Create(node1.id, node2.id)))
                                {
                                    edgesC.Add(Tuple.Create(component1, component2));
                                    edgeFound = true;
                                }
                                if (edgeFound)
                                    break;
                            }
                            if (edgeFound)
                                break;
                        }
                    }
                }
            }
            Graph graphC = new Graph(nodesC, edgesC);
            return graphC;
        }

        private static HashSet<Node> strongconnect(Node node)
        {
            node.index = index;
            node.lowlink = index;
            index++;
            S.Push(node);

            //TODO  get only edges that originate from our node. not all of them
            foreach (var edge in edges )
            {
                if (edge.Item1 == node.id)
                {
                    String src = edge.Item1;
                    String dest = edge.Item2;
                    if (nodes[dest].index < 0)
                    {
                        strongconnect(nodes[dest]);
                        nodes[src].lowlink = Math.Min(nodes[src].lowlink, nodes[dest].lowlink);
                    }
                    else if (S.Contains(nodes[dest]))
                    {
                        nodes[src].lowlink = Math.Min(nodes[src].lowlink, nodes[dest].index);
                    }
                }
            }

            if (node.lowlink == node.index)
            {
                HashSet<Node> component = new HashSet<Node>();
                Node w = new Node();
                do
                {
                    w = S.Pop();
                    component.Add(w);
                } while (w.id != node.id);
                return component;
            }
            return null;
        }
    }
}
