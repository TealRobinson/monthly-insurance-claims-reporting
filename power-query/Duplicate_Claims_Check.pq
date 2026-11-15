let
    Source = #"Southern_Lantern_Claims_Jan-Mar_2026_Raw_and_Brief",
    #"Kept Duplicates" = let columnNames = {"Claim_ID"}, addCount = Table.Group(Source, columnNames, {{"Count", Table.RowCount, type number}}), selectDuplicates = Table.SelectRows(addCount, each [Count] > 1), removeCount = Table.RemoveColumns(selectDuplicates, "Count") in Table.Join(Source, columnNames, removeCount, columnNames, JoinKind.Inner)
in
    #"Kept Duplicates"
