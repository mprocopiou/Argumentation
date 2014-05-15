using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace Parser
{
    class Parser
    {
        public static Dictionary<String, HashSet<ProgramNode>> edb = new Dictionary<string,HashSet<ProgramNode>>();
        public static Dictionary<string,HashSet<ProgramNode>> idb = new Dictionary<string, HashSet<ProgramNode>>();
        public static Dictionary<String, HashSet<Tuple<String,String>>> depGraph = new Dictionary<string, HashSet<Tuple<String,String>>>();

        public static string startParsing(string input)
        {
            List<ProgramNode> program = new List<ProgramNode>();
            Grounder grounder = new Grounder();
            string prologInput = "";
            string errorMsg = "";
            //Test String for dependency graph creation.
            //string test = "asm(aasdd,b){X=1,2;}.t(X) <- [p(X),aasdd(X)].p(X)<- [r(X)].r(X) <-[aasdd(X)].";
            //string test = "asm(aasdd,b){X=1,2;}.t(X) <- [p(X),aasdd(X)]. p(X)<- [r(X)]. s(X) <- [r(X)].p(X)<-[r(X),t(X)].r(X) <-[aasdd(X)].";
            string test = input;
            //string test = "asm(aasdd,b)\t {X=a, b, c,d;Y=1,2,3; }.asm(e,z) {X=1,2;Y=2,3;}. aba <- [c,d] {a, e ,f ,s , g ,ffdf}. Something something";
            string[] split = test.Split(new char[] { '.' }, StringSplitOptions.RemoveEmptyEntries);
            foreach (string s in split)
            {
                string line = System.Text.RegularExpressions.Regex.Replace(s, @"\s", "");
                // if (s.Substring(0, 4).CompareTo(@"asm(") == 0)
                // TODO REGEX FOR DOMAIN DOES NOT CAPTURE ERRORS>> MUST CHANGE ACCORDINGLY. Matches just asm part and succeeds
                if (Regex.IsMatch(line, @"asm\(([A-Za-z0-9]+),([A-Za-z0-9]+)\)(\{(([A-Z]*=[A-Za-z0-9])+(,[A-Za-z0-9])*;)+\})?"))
                {
                    //Match grouped Regex.                    
                    string[] seperators = new string[] { @"asm(", ")", "{", "}" };
                    // Seperates in IDs and domain.
                    string[] tokens = line.Split(seperators, StringSplitOptions.RemoveEmptyEntries);
                    // Seperates in Assumption ID and Contrary ID.
                    string[] variables = tokens[0].Split(',');
                    //     Assumption asmObject = new Assumption();
                    //     asmObject.id = variables[0];
                    string assumption = variables[0];
                    string contrary = variables[1];
                    string output = "";
                    if (tokens.Length > 1)
                    {
                        // Generates all possible combinations of domain.
                        List<string[]> combinations = parseDomain(tokens[1]);

                        output= addToEDB(combinations, assumption, contrary);
                        // TODO DELETE CODE BELOW WHEN SURE ITS OK.
                        //string[][] fulldomain = new string[2][];
                        //string[] variable = tokens[1].Split(',');
                        //fulldomain[0] = variable;
                        //fulldomain[1] = variable;
                        //foreach (String var1 in fulldomain[0])
                        //{
                        //    foreach (String var2 in fulldomain[1])
                        //    {
                        //        var parms = Tuple.Create(var1, var2);
                        //    }
                        //}

                        //        asmObject.variables = domain;
                    }
                    //      grounder.addToEDB(asmObject);
                    //string output = String.Format("myAsm({0}).\ncontrary({0},{1}).\n", assumption, contrary);
                    prologInput = prologInput + output;
                }
                else if (Regex.IsMatch(line, @"[A-Za-z0-9()]+<-\[([A-Za-z0-9()]+(,[A-Za-z0-9()]+)*)?\](\{([A-Za-z0-9])+(,[A-Za-z0-9])*\})?"))
                {
                    string[] seperators = new string[] { @"<-", "[", "]", "{", "}" };
                    string[] tokens = line.Split(seperators, StringSplitOptions.RemoveEmptyEntries);
                    
                    string rule = tokens[0];
                    Literal head = getHead(rule);

                    string[] terms = tokens[1].Split(',');
                    List<Literal> termList = getTerms(terms);
                    // TODO Domain needs fixing for Rule parsing.
                    string[] domain = null;
                    if (tokens.Length > 2)
                    {
                        domain = tokens[2].Split(',');                        
                    }

                    Rule ruleObj = new Rule(head.id, termList, head.variables);                    
                    addToDepGraph(ruleObj);
                    if (idb.ContainsKey(ruleObj.id))
                        idb[ruleObj.id].Add(ruleObj);
                    else
                    {
                        HashSet<ProgramNode> ruleTemp = new HashSet<ProgramNode>();
                        ruleTemp.Add(ruleObj);
                        idb.Add(ruleObj.id, ruleTemp);
                    }
                    program.Add(ruleObj);
                    string output = String.Format("myRule({0}, [{1}]).\n", rule, tokens[1]);
                //    prologInput = prologInput + output;
                }
                else
                {
                    errorMsg = errorMsg + "Invalid statement: " + s + "\n";
                }
            }
            Graph graphC = SCC.generateComponentGraph(depGraph);

            List<HashSet<Node>> sccOrder = new List<HashSet<Node>>();
            sccOrder = deriveOrdering(graphC);

            List<ProgramNode> groundedProgram = Grounder.instantiate(graphC, program, sccOrder, edb);
            foreach (var rule in groundedProgram)
            {
                string headVars;
                if (rule.variables != null)
                {
                    headVars = String.Format("({0})",String.Join(",", rule.variables));
                }
                else
                {
                    headVars = "";
                }
                string head = String.Format("{0}{1}", rule.id, headVars);
                Rule tempRule = (Rule) rule;
                List<String> predList = new List<String>();
                foreach (var pred in tempRule.predicates)
                {
                    string predString;
                    if (rule.variables != null)
                    {
                        predString = String.Format("({0})", String.Join(",", pred.variables));
                    }
                    else
                    {
                        predString = "";
                    }
                    predString = pred.id + predString;
                    predList.Add(predString);
                }
                String preds = String.Join(",", predList);
                string line = String.Format("myRule({0}, [{1}]).\n", head , preds);
                prologInput = prologInput + line; 
            }
            return prologInput;
           // Console.Write(prologInput);
          //  Console.Write(errorMsg);
         //   Console.Read();
        }

        private static List<Literal> getTerms(string[] terms)
        {
            List<Literal> termList = new List<Literal>();           
            foreach (var term in terms)
            {
                Literal newterm = new Literal();
                string[] parts = term.Split(new char[] { '(', ')' });
                newterm.id = parts[0];
                newterm.variables = parts[1].Split(',');
                termList.Add(newterm);
            }
            return termList;
        }

        private static Literal getHead(string p)
        {

            string[] elements = p.Split(new char[] { '(', ')' });
            Literal lit = new Literal();
            lit.id = elements[0];
            lit.variables = elements[1].Split(',');
            return lit;
        }

        private static List<HashSet<Node>> deriveOrdering(Graph graphC)
        {
            List<HashSet<Node>> ordering = new List<HashSet<Node>>();
            foreach (var component in graphC.nodes)
            {
                // Add first element to order list.
                if (ordering.Count() == 0) {
                    ordering.Add(component);
                }
                else 
                {
                    int index = 0;
                    foreach (var elem in ordering)
                    {
                        if (graphC.edges.Contains(Tuple.Create(component, elem)))
                        {
                            ordering.Insert(index, component);
                            break;
                        }
                        else if (ordering.Last() == elem)
                        {
                            ordering.Add(component);
                            break;
                        }
                        else
                            index++;
                    }
                }
            }
            return ordering;
        }
        // Used to build Dependency graph for grounder at incrementally for each rule parsed.
        private static void addToDepGraph(Rule rule)
        {
            // Check if rule already recorded in Graph.
            if (depGraph.ContainsKey(rule.id))
            {
                // Gets existing Predicates recorded so far.
                HashSet<Tuple<String,String>> existPreds = depGraph[rule.id];
                // Creates and appends any new predicates.
                foreach (var pred in rule.predicates)
                {
                    if (!edb.ContainsKey(pred.id))
                    existPreds.Add(Tuple.Create(pred.id,rule.id));
                }
                // Replaces with updated set.
                depGraph[rule.id] = existPreds;
            }
            // Same as above.
            else
            {
                HashSet<Tuple<String,String>> newPreds = new HashSet<Tuple<String,String>>();
                foreach (var pred in rule.predicates)
                {
                    if (!edb.ContainsKey(pred.id))
                    newPreds.Add(Tuple.Create(pred.id,rule.id));
                }
                depGraph.Add(rule.id, newPreds);
            }   
        }

        public static String addToEDB(List<string[]> combinations, string assumptionID, string contraryID)
        {
            string combString = "";
            foreach (var comb in combinations)
            {
                Assumption assumption = new Assumption();
                assumption.id = assumptionID;
                assumption.variables = comb;                
                string assumString = String.Format("myAsm({0}({1})).\n", assumption.id, String.Join(",",assumption.variables));

                Assumption contrary = new Assumption();
                contrary.id = contraryID;
                contrary.variables = comb;
                string contString = String.Format("contrary({0}({1}),{2}({1})).\n", assumption.id, String.Join(",",contrary.variables),contrary.id);


                if (edb.ContainsKey(assumptionID))
                {
                    HashSet<ProgramNode> existAsm = edb[assumptionID];
                    existAsm.Add(assumption);
                    edb[assumptionID] = existAsm;

                    HashSet<ProgramNode> existCont = edb[contraryID];
                    existCont.Add(contrary);
                    edb[contraryID] = existCont;
                }
                else
                {
                    HashSet<ProgramNode> newAsm = new HashSet<ProgramNode>();
                    newAsm.Add(assumption);
                    edb.Add(assumptionID, newAsm);

                    HashSet<ProgramNode> newCont = new HashSet<ProgramNode>();
                    newCont.Add(contrary);
                    edb.Add(contraryID, newCont);
                }
                combString = combString + assumString + contString;
            }
            return combString;
        }

        public static List<string[]> parseDomain(string domain)
        {

            // TEST STRING 
            // string domain = "X=1,2,3;Y=1,2;";            
            String[] variables = domain.Split(new char[] { ';' }, StringSplitOptions.RemoveEmptyEntries);
            String[][] parsedDomain = new String[variables.Length][];
            int counter = 0;
            foreach (String variable in variables)
            {
                String[] varElems = variable.Split('=');
                parsedDomain[counter] = varElems[1].Split(',');
                counter++;
            }

            int numVariable = parsedDomain.Length-1;
            string[] combination = new string[parsedDomain.Length];
            List<string[]> final = new List<string[]>();
            createCombinations(parsedDomain, numVariable, combination, final);
            return final;
        }

        private static void createCombinations(string[][] parsedDomain, int numVariable, string[] combination, List<string[]> final)
        {
            if (numVariable == 0)
            {
                foreach (var elem in parsedDomain[0])
                {
                    combination[0] = elem;
                    string[] addComb = new string[parsedDomain.Length];
                    addComb = (string[]) combination.Clone();
                    final.Add(addComb);
                }
            }
            else
            {
                foreach (var elem in parsedDomain[numVariable])
                {
                    combination[numVariable] = elem;
                    createCombinations(parsedDomain, numVariable - 1, combination, final);
                }
            }
        }

    }
}
