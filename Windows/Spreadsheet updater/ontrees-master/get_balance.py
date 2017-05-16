from time import sleep
from decimal import Decimal, getcontext
import time
import datetime
from datetime import date
from dateutil.relativedelta import relativedelta
import calendar
from calendar import monthrange
from datetime import timedelta



import ontrees

otc = ontrees.Client(email="lovatt_adam@hotmail.com", password="musstard52")

print "Attempting to log in"
if otc.login():
    print "Login successful"
else:
    print "Login failed, please check your credentials. Aborting."
    exit()

print "Getting linked banks..."
linked_banks = otc.get_linked_banks()
if linked_banks:
    print "Found {0} linked banks(s)".format(len(linked_banks))
else:
    print "Request failed. Aborting"
    exit()

print "Refreshing accounts..."
refresh_count = otc.start_refresh_linked_banks(linked_banks)
print "{0} banks refreshed".format(refresh_count)

# wait 60 seconds if there are accounts being refreshed
if refresh_count > 0:
    print "Waiting 60 seconds to allow all banks to have been refreshed. "
    sleep(60)
    # Refresh linked banks
    linked_banks = otc.get_linked_banks()

# Print a list of accounts
accounts = otc.get_accounts(linked_banks)
print

#Figure out current balance
overdraft_facility = 550
club_lloyds = accounts[1]
club_lloyds_balance = club_lloyds['AvailableBalance'] - overdraft_facility
#print club_lloyds_balance

##How many days left in the month

# Figure out which is next payday

today = datetime.date.today()
nextmonth = datetime.date.today() + relativedelta(months=+1)
if today.day <= 27:
	nextpaymonth = today.month
else:
	nextpaymonth = nextmonth.month

# Figure out how many days there are till payday

thisday = datetime.datetime.now()
payday = datetime.datetime(today.year,nextpaymonth,27)
daysleft = (payday-thisday).days
#print daysleft

# Figure out how many days are in the month

paymonthdays = monthrange(today.year, nextpaymonth)
monthdays = paymonthdays[1]
#print monthdays


#Dump vars to text file for Powershell

file = open("Vars.ps1","w")
file.write("$balance = " + str(club_lloyds_balance) + '\n' )
file.write("$daysleft = " + str(daysleft) + '\n' )
file.write("$monthdays = " + str(monthdays) + '\n' )

file.close()

bob = 10

if bob < 11:
    print bob
else
    print "bob doesnt have enough money"
