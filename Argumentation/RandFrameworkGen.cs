using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace RandomFrameworkGenerator
{
    class RandFrameworkGen
    {
        public static int[] domainA = new int[] { 1, 2, 3, 4, 5, 6, 7 };
        public static int[] domainB = new int[] { 5, 6, 7 ,8 ,9 };
        static Random rnd = new Random();

        public static List<String> genRandFramewor()
        {
            Dictionary<String, String> assumCont = new Dictionary<string, string>();
            Queue<String> assumQ = new Queue<string>();
            Queue<String> ruleQ = new Queue<string>();
            ruleQ.Enqueue("a");
            List<String> framework = new List<string>();
            List<String> frameworkAssums = new List<string>();
            List<String> frameworkRules = new List<string>();
            List<String> startSymbls = getStartList2();
            List<String> availableSymbls = startSymbls.ToList<String>();
            while ((assumQ.Count > 0 || ruleQ.Count > 0) && availableSymbls.Count > 0)
            {
                if (assumQ.Count > 0)
                {
                    string temp = assumQ.Dequeue();
                    frameworkAssums.Add(createAsm(temp, startSymbls, assumCont));
                }
                else
                {
                    string temp = ruleQ.Dequeue();
                    frameworkRules.Add(createRule(temp, availableSymbls, assumQ, ruleQ));
                }
            }
            foreach (var elem in frameworkAssums)
                framework.Add(elem);
            foreach (var elem in frameworkRules)
                framework.Add(elem);
            //Console.WriteLine("RUN!");
            //Console.WriteLine("------------------------");
            //foreach (var line in framework) 
            //    Console.WriteLine(line);
            //Console.Read();
            return framework;

        }

        private static string createRule(string id, List<string> availableSymbls, Queue<string> assumQ, Queue<string> ruleQ)
        {
            HashSet<String> terms = new HashSet<string>();
            int numTerms = rnd.Next(3) + 1;
            terms = createTerms(availableSymbls,numTerms);
            addToQueue(terms, assumQ, ruleQ);
            string head = String.Format(@"{0}(X)",id);
            string termStr = string.Join(",", terms.Select(x => x.ToString()).ToArray());
            string line = String.Format(@"{0}<-[{1}].", head, termStr);
            return line;
        }

        private static void addToQueue(HashSet<string> terms, Queue<string> assumQ, Queue<string> ruleQ)
        {
            foreach (var term in terms)
            {
                string termQ = term.Replace("(X)", "");
                int choice = rnd.Next(4);
                if (choice == 0)
                {
                    assumQ.Enqueue(termQ);
                }
                else
                {
                    ruleQ.Enqueue(termQ);
                }
            }
        }

        private static HashSet<String> createTerms(List<string> availableSymbls, int numTerms)
        {
            HashSet<String> terms = new HashSet<string>();
            if (availableSymbls.Count < numTerms)
            {
                numTerms = availableSymbls.Count;
            }
            while (numTerms > 0)
            {
                int index = rnd.Next(availableSymbls.Count - 1);
                string termStr = String.Format(@"{0}(X)", availableSymbls[index]);
                if(terms.Add(termStr))
                {
                    numTerms--;
                    availableSymbls.RemoveAt(index);
                }
            }
            return terms;
        }

        private static string createAsm(string id,List<String> startSymbls, Dictionary<string, string> assumCont)
        {
            string contr = pickRandContrary(id, startSymbls);
            string assumStr = String.Format(@"{0}(X)", id);
            string contrStr = String.Format(@"{0}(X)", contr);
            int chooseDomain = rnd.Next(100);
            int[] domain;
            assumCont.Add(assumStr,contrStr);
            if (chooseDomain % 2 == 0)
                domain = domainA;
            else
                domain = domainB;
            string domainStr = string.Join(",", domain.Select(x => x.ToString()).ToArray());
            string line = String.Format(@"asm({0},{1}){{X={2};}}.", assumStr, contrStr, domainStr);
            return line;
        }

        private static string pickRandContrary(string id, List<String> startSymbls)
        {
            int r = rnd.Next(startSymbls.Count - 1);
            while (startSymbls[r] == id)
            {
                r = rnd.Next(startSymbls.Count - 1);
            }
            return startSymbls[r];
        }

        private static List<string> getStartList()
        {
            List<string> startSymbls = new List<string>();
            char[] charList = "bcdefghijklmnopqrstuvwxyz".ToCharArray();
            foreach(var c in charList) 
            {
                startSymbls.Add(c.ToString());
            }
            return startSymbls;
        }

        private static List<string> getStartList2()
        {
            List<string> startSymbls = new List<string>();
            char[] charList = "bcdefghijklmnopqrstuvwxyz".ToCharArray();
            foreach (var x in charList)
            {
                foreach (var y in charList)
                {
                    string toAdd = x.ToString() + y.ToString();
                    startSymbls.Add(toAdd.ToString());
                }
            }
            return startSymbls;
        }
    }
}
