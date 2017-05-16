#Get Vars
bash.exe -c "/usr/bin/python /mnt/c/Users/alovatt/Documents/Scripts/Windows/Spreadsheet\ updater/ontrees-master/get_balance.py"
. ./Vars.ps1

$Path = 'C:\Users\alovatt\Documents\Scripts\Windows\Spreadsheet updater\Finances.xls'


# Open the Excel document and pull in the 'Ins and outs' worksheet
$Excel = New-Object -ComObject Excel.Application
$ExcelWorkBook = $Excel.Workbooks.Open($Path)
$ExcelWorkSheet = $Excel.WorkSheets.item("money")
$ExcelWorkSheet.activate()

# Populate relevent cells
$ExcelWorkSheet.Cells.Item(17,7) = $balance
$ExcelWorkSheet.Cells.Item(39,2) = $monthdays
$ExcelWorkSheet.Cells.Item(38,2) = $daysleft
$ExcelWorkBook.Save()
$ExcelWorkBook.Close()
$Excel.Quit()
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($Excel)
Stop-Process -Name EXCEL -Force
