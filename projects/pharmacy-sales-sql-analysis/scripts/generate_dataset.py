import random, csv
from datetime import date, timedelta
random.seed(42)

products = [
 ("Paracetamol 500mg","Analgesic",150),("Ibuprofen 400mg","Analgesic",300),
 ("Amoxicillin 500mg","Antibiotic",900),("Ciprofloxacin 500mg","Antibiotic",1200),
 ("Artemether/Lumefantrine","Antimalarial",1800),("Metformin 500mg","Antidiabetic",600),
 ("Amlodipine 5mg","Antihypertensive",700),("Lisinopril 10mg","Antihypertensive",850),
 ("Loratadine 10mg","Antihistamine",400),("Omeprazole 20mg","Gastrointestinal",500),
 ("Vitamin C 1000mg","Supplement",350),("ORS Sachet","Rehydration",200),
 ("Salbutamol Inhaler","Respiratory",2500),("Metronidazole 400mg","Antibiotic",450),
]
branches = ["Osogbo","Ilesa","Ede","Ikirun","Iwo"]
pay = ["Cash","Transfer","POS"]
rows=[]
start=date(2025,1,1)
for i in range(1,1501):
    p=random.choice(products)
    d=start+timedelta(days=random.randint(0,364))
    qty=random.randint(1,12)
    price=p[2]
    rows.append({
     "sale_id":1000+i,"sale_date":d.isoformat(),"branch":random.choice(branches),
     "product_name":p[0],"category":p[1],"quantity":qty,"unit_price":price,
     "total_amount":qty*price,"payment_method":random.choice(pay),
     "customer_age":random.randint(1,85)})
key=[]
n=len(rows)
def pick(k): return random.sample(range(n),k)
# 1 duplicates
dups=pick(25)
for i in dups: rows.append(dict(rows[i]))
key.append(("Exact duplicate rows","25 rows duplicated (same sale_id appears twice)"))
# 2 casing/whitespace in branch
for i in pick(60):
    rows[i]["branch"]=random.choice([rows[i]["branch"].upper(),rows[i]["branch"].lower(),"  "+rows[i]["branch"]+" "])
key.append(("Inconsistent branch text","60 rows with uppercase, lowercase or stray spaces"))
# 3 payment method variants
for i in pick(50):
    rows[i]["payment_method"]=random.choice(["cash","CASH","pos","Bank Transfer","transfer"])
key.append(("Payment method variants","50 rows, e.g. cash, CASH, pos, Bank Transfer"))
# 4 nulls
for i in pick(40): rows[i]["customer_age"]=""
for i in pick(30): rows[i]["category"]=""
for i in pick(20): rows[i]["payment_method"]=""
key.append(("Missing values","40 blank customer_age, 30 blank category, 20 blank payment_method"))
# 5 impossible ages
for i in pick(12): rows[i]["customer_age"]=random.choice([0,-5,150,999])
key.append(("Impossible ages","12 rows with ages like 0, -5, 150, 999"))
# 6 negative or zero quantity
for i in pick(10):
    rows[i]["quantity"]=random.choice([0,-1,-3])
key.append(("Invalid quantities","10 rows with zero or negative quantity (total_amount no longer matches)"))
# 7 wrong totals
for i in pick(35): rows[i]["total_amount"]=rows[i]["total_amount"]+random.choice([-100,50,200,500])
key.append(("Total mismatch","About 35 rows where total_amount does not equal quantity x unit_price"))
# 8 bad dates
for i in pick(18):
    d=rows[i]["sale_date"]; y,m,dd=d.split("-")
    rows[i]["sale_date"]=random.choice([f"{dd}/{m}/{y}",f"{y}/{m}/{dd}","2026-13-05","2025-02-30"])
key.append(("Mixed or invalid date formats","18 rows with dd/mm/yyyy, slashes, or impossible dates"))
# 9 price outliers
for i in pick(8):
    rows[i]["unit_price"]=rows[i]["unit_price"]*random.choice([10,100])
key.append(("Price outliers","8 rows with unit_price 10x or 100x too high"))
# 10 product name typos
typos={"Paracetamol 500mg":"Paracetamol 500 mg","Amoxicillin 500mg":"Amoxycillin 500mg","Metformin 500mg":"metformin 500mg","Ibuprofen 400mg":"Ibuprofen 400MG"}
for i in pick(80):
    if rows[i]["product_name"] in typos: rows[i]["product_name"]=typos[rows[i]["product_name"]]
key.append(("Product name inconsistencies","Spelling and casing variants of product_name (Paracetamol, Amoxicillin, Metformin, Ibuprofen)"))
random.shuffle(rows)
with open("pharmacy_sales_raw.csv","w",newline="") as f:
    w=csv.DictWriter(f,fieldnames=list(rows[0].keys())); w.writeheader(); w.writerows(rows)
with open("ANSWER_KEY_open_after_you_finish.md","w") as f:
    f.write("# Answer key: planted data issues\n\nCounts are approximate because some issues overlap on the same rows.\n\n")
    for a,b in key: f.write(f"- **{a}**: {b}\n")
print(len(rows))
