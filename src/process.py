import pandas as pd

conversion = {
    "object": "TEXT",
    "float64": "NUMERIC",
    "int64": "INTEGER"
}

tables = {
    "BenefitsCostSharing": {
        # 2016 removed two fields: 'IsSubjToDedTier2', 'IsSubjToDedTier1
        "2016": "input/2016/Benefits_Cost_Sharing_PUF_2015-12-08.csv",
        "2015": "input/2015/Benefits_Cost_Sharing_PUF.csv",
        "2014": "input/2014/Benefits_Cost_Sharing_PUF.csv"
    },
    "BusinessRules": {
        # 2016 renamed DentalOnly => DentalOnlyPlan
        "2016": "input/2016/Business_Rules_PUF_2015-12-08.csv",
        "2015": "input/2015/Business_Rules_PUF_Reformat.csv",
        "2014": "input/2014/Business_Rules_PUF.csv"
    },
    "Crosswalk2015": {
        "data": "input/2015/Plan_Crosswalk_PUF_2014-12-22.csv"
    },
    "Crosswalk2016": {
        "data": "input/2016/Plan_ID_Crosswalk_PUF_2015-12-07.CSV"
    },
    "Network": {
        # 2016 renamed DentalOnly => DentalOnlyPlan
        "2016": "input/2016/Network_PUF_2015-12-08.csv",
        "2015": "input/2015/Network_PUF.csv",
        "2014": "input/2014/Network_PUF.csv"
    },
    "PlanAttributes": {
        # This is complicated - lots of fields change b/t 2014/2015 & 2016
        "2016": "input/2016/Plan_Attributes_PUF_2015-12-08.csv",
        "2015": "input/2015/Plan_Attributes_PUF.csv",
        "2014": "input/2014/Plan_Attributes_PUF_2014_2015-03-09.csv"
    },
    "Rate": {
        # 2016 same structure as 2015 and 2014
        "2016": "input/2016/Rate_PUF_2015-12-08.csv",
        "2015": "input/2015/Rate_PUF.csv",
        "2014": "input/2014/Rate_PUF.csv"
    },
    "ServiceArea": {
        # 2016 renamed DentalOnly => DentalOnlyPlan
        "2016": "input/2016/ServiceArea_PUF_2015-12-08.csv",
        "2015": "input/2015/Service_Area_PUF.csv",
        "2014": "input/2014/Service_Area_PUF.csv"
    }
}


sql = """.separator ","

"""

for table in tables:
    print(table)

    if table[:9] != "Crosswalk":
        d2016 = pd.read_csv(tables[table]["2016"], encoding="latin1", low_memory=False)
        d2015 = pd.read_csv(tables[table]["2015"], encoding="latin1", low_memory=False)
        d2014 = pd.read_csv(tables[table]["2014"], encoding="latin1", low_memory=False)

        # code to debug differences
        # print(len(d2016.columns), d2016.columns)
        # d2016_2015 = set(d2016.columns).symmetric_difference(set(d2015.columns))
        # print("2016 v 2015: ", len(d2016_2015), " : ", d2016_2015)
        # d2016_2014 = set(d2016.columns).symmetric_difference(set(d2014.columns))
        # print("2016 v 2014: ", len(d2016_2014), " : ", d2016_2014)
        # d2015_2014 = set(d2015.columns).symmetric_difference(set(d2014.columns))
        # print("2015 v 2014: ", len(d2015_2014), " : ", d2015_2014)

        if table in ["ServiceArea", "BusinessRules", "Network"]:
            d2015 = d2015.rename(columns={"DentalOnly":"DentalOnlyPlan"})
            d2014 = d2014.rename(columns={"DentalOnly":"DentalOnlyPlan"})

        if table=="BenefitsCostSharing":
            d2015 = d2015.rename(columns={"EHBPercentPremiumS4":"EHBPercentTotalPremium"})
            d2014 = d2014.rename(columns={"EHBPercentPremiumS4":"EHBPercentTotalPremium"})

        if table != "Crosswalk":
            data = pd.concat([d2014, d2015, d2016])
        else:
            data = pd.concat([d2015, d2016])
    else:
        data = pd.read_csv(tables[table]["data"], encoding="latin1", low_memory=False)

    data.to_csv("output/%s.csv" % table, index=False)
    data = read_csv("output/%s.csv" % table, low_memory=False)

    sql += """CREATE TABLE %s (
%s);

.import "working/noHeader/%s.csv" %s

""" % (table,
       ",\n".join(["    %s %s%s" % (key,
                                   conversion[str(data.dtypes[key])],
                                   " PRIMARY KEY" if key=="Id" else "")
                   for key in data.dtypes.keys()]), table, table)

open("working/import.sql", "w").write(sql)

# 
# input/2015/Plan_Crosswalk_PUF_2014-12-22.csv
# 