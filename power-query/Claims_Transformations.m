let
    Source = Folder.Files("C:\Path\To\Your\Monthly_Claims_CSVs"),

    #"Filtered Hidden Files1" = Table.SelectRows(
        Source,
        each [Attributes]?[Hidden]? <> true
    ),

    #"Invoke Custom Function1" = Table.AddColumn(
        #"Filtered Hidden Files1",
        "Transform File",
        each #"Transform File"([Content])
    ),

    #"Renamed Columns1" = Table.RenameColumns(
        #"Invoke Custom Function1",
        {{"Name", "Source.Name"}}
    ),

    #"Removed Other Columns1" = Table.SelectColumns(
        #"Renamed Columns1",
        {"Source.Name", "Transform File"}
    ),

    #"Expanded Table Column1" = Table.ExpandTableColumn(
        #"Removed Other Columns1",
        "Transform File",
        Table.ColumnNames(#"Transform File"(#"Sample File"))
    ),

    #"Changed Type" = Table.TransformColumnTypes(
        #"Expanded Table Column1",
        {
            {"Source.Name", type text},
            {"Claim_ID", type text},
            {"Policy_ID", type text},
            {"Payment_Date", type date},
            {"Claim_Type", type text},
            {"Region_Location", type text},
            {"State", type text},
            {"Handler_Contact", type text},
            {"Paid_Amount_AUD", type text},
            {"Payment_Method", type text},
            {"Claim_Notes", type text}
        }
    ),

    #"Capitalized Each Word" = Table.TransformColumns(
        #"Changed Type",
        {{"Claim_Type", Text.Proper, type text}}
    ),

    #"Uppercased Text" = Table.TransformColumns(
        #"Capitalized Each Word",
        {{"State", Text.Upper, type text}}
    ),

    #"Split Column by Delimiter" = Table.SplitColumn(
        #"Uppercased Text",
        "Region_Location",
        Splitter.SplitTextByDelimiter("|", QuoteStyle.Csv),
        {"Region_Location.1", "Region_Location.2"}
    ),

    #"Renamed Columns" = Table.RenameColumns(
        #"Split Column by Delimiter",
        {
            {"Region_Location.1", "Region"},
            {"Region_Location.2", "Location"}
        }
    ),

    #"Trimmed Text" = Table.TransformColumns(
        Table.TransformColumnTypes(
            #"Renamed Columns",
            {{"Payment_Date", type text}},
            "en-GB"
        ),
        {
            {"Source.Name", Text.Trim, type text},
            {"Claim_ID", Text.Trim, type text},
            {"Policy_ID", Text.Trim, type text},
            {"Payment_Date", Text.Trim, type text},
            {"Claim_Type", Text.Trim, type text},
            {"Region", Text.Trim, type text},
            {"Location", Text.Trim, type text},
            {"State", Text.Trim, type text},
            {"Handler_Contact", Text.Trim, type text},
            {"Paid_Amount_AUD", Text.Trim, type text},
            {"Payment_Method", Text.Trim, type text},
            {"Claim_Notes", Text.Trim, type text}
        }
    ),

    #"Replaced Value" = Table.ReplaceValue(
        #"Trimmed Text",
        "QUEENSLAND",
        "QLD",
        Replacer.ReplaceText,
        {"State"}
    ),

    #"Replaced Value1" = Table.ReplaceValue(
        #"Replaced Value",
        "WESTERN AUSTRALIA",
        "WA",
        Replacer.ReplaceText,
        {"State"}
    ),

    #"Replaced Value2" = Table.ReplaceValue(
        #"Replaced Value1",
        "NEW SOUTH WALES",
        "NSW",
        Replacer.ReplaceText,
        {"State"}
    ),

    #"Capitalized Each Word1" = Table.TransformColumns(
        #"Replaced Value2",
        {{"Region", Text.Proper, type text}}
    ),

    #"Extracted Text Before Delimiter" = Table.TransformColumns(
        #"Capitalized Each Word1",
        {
            {
                "Handler_Contact",
                each Text.BeforeDelimiter(_, "|"),
                type text
            }
        }
    ),

    #"Split Column by Delimiter1" = Table.SplitColumn(
        #"Extracted Text Before Delimiter",
        "Handler_Contact",
        Splitter.SplitTextByDelimiter("(", QuoteStyle.Csv),
        {"Handler_Contact.1", "Handler_Contact.2"}
    ),

    #"Changed Type1" = Table.TransformColumnTypes(
        #"Split Column by Delimiter1",
        {
            {"Handler_Contact.1", type text},
            {"Handler_Contact.2", type text}
        }
    ),

    #"Replaced Value3" = Table.ReplaceValue(
        #"Changed Type1",
        ")",
        "",
        Replacer.ReplaceText,
        {"Handler_Contact.2"}
    ),

    #"Renamed Columns2" = Table.RenameColumns(
        #"Replaced Value3",
        {
            {"Handler_Contact.2", "Handler_Email"},
            {"Handler_Contact.1", "Handler"}
        }
    ),

    #"Duplicated Column" = Table.DuplicateColumn(
        #"Renamed Columns2",
        "Paid_Amount_AUD",
        "Paid_Amount_AUD - Copy"
    ),

    #"Reordered Columns" = Table.ReorderColumns(
        #"Duplicated Column",
        {
            "Source.Name",
            "Claim_ID",
            "Policy_ID",
            "Payment_Date",
            "Claim_Type",
            "Region",
            "Location",
            "State",
            "Handler",
            "Handler_Email",
            "Paid_Amount_AUD - Copy",
            "Paid_Amount_AUD",
            "Payment_Method",
            "Claim_Notes"
        }
    ),

    #"Renamed Columns3" = Table.RenameColumns(
        #"Reordered Columns",
        {
            {"Paid_Amount_AUD - Copy", "Paid_Amount_RAW"}
        }
    ),

    #"Replaced Value4" = Table.ReplaceValue(
        #"Renamed Columns3",
        "TBC",
        null,
        Replacer.ReplaceValue,
        {"Paid_Amount_AUD"}
    ),

    #"Changed Type2" = Table.TransformColumnTypes(
        #"Replaced Value4",
        {{"Paid_Amount_AUD", Currency.Type}}
    ),

    #"Renamed Columns4" = Table.RenameColumns(
        #"Changed Type2",
        {
            {"Paid_Amount_RAW", "Paid_Amount_Raw"}
        }
    ),

    #"Added Payment Status" = Table.AddColumn(
        #"Renamed Columns4",
        "Payment_Status",
        each
            if [Paid_Amount_Raw] = "TBC"
                then "To Be Confirmed"
            else if [Paid_Amount_AUD] = null
                then "Missing Amount"
            else if [Paid_Amount_AUD] = 0
                then "Zero Payment - Review"
            else
                "Amount Recorded",
        type text
    ),
    #"Reordered Columns1" = Table.ReorderColumns(#"Added Payment Status",{"Source.Name", "Claim_ID", "Policy_ID", "Payment_Date", "Claim_Type", "Region", "Location", "State", "Handler", "Handler_Email", "Paid_Amount_Raw", "Paid_Amount_AUD", "Payment_Status", "Payment_Method", "Claim_Notes"}),
    #"Capitalized Each Word2" = Table.TransformColumns(#"Reordered Columns1",{{"Claim_Notes", Text.Proper, type text}}),
    #"Changed Type3" = Table.TransformColumnTypes(#"Capitalized Each Word2",{{"Payment_Date", type date}}),
    #"Capitalized Each Word3" = Table.TransformColumns(#"Changed Type3",{{"Payment_Method", Text.Proper, type text}}),
    #"Replaced Value5" = Table.ReplaceValue(#"Capitalized Each Word3","Eft","Electronic Funds Transfer",Replacer.ReplaceText,{"Payment_Method"}),
    #"Removed Duplicates" = Table.Distinct(#"Replaced Value5", {"Claim_ID"}),
    #"Replaced Value6" = Table.ReplaceValue(#"Removed Duplicates","VICTORIA","VIC",Replacer.ReplaceText,{"State"})
in
    #"Replaced Value6"