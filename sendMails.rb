# number of categories up from, down form. Count rows in catIDs 
require 'net/smtp'
#require 'gmail'

def sendMails(env, tenant)
    
puts "sending mail"

if env == 'www'  
	env = 'production' 
end

#mailingList = "hagai.galai@autodesk.com, nir.bilgory@autodesk.com, ayman@cmycasa.com, maayan@cmycasa.com"
#mailingList = "hagai.galai@autodesk.com, nir.bilgory@autodesk.com, maayan@cmycasa.com, ayman@cmycasa.com, liat.eagle@autodesk.com, uzi.berko@autodesk.com, tal.negrin@autodesk.com"
#mailingListCC = "guy.morad@autodesk.com, moshe.almog@autodesk.com, yongmei.wang@autodesk.com, ada.zhong@autodesk.com, tian.tian@autodesk.com, William.Jin@autodesk.com"
mailingList = ['homestyler.web.qa@autodesk.com','hagai.galai@autodesk.com','nir.bilgory@autodesk.com','maayan@cmycasa.com','ayman@cmycasa.com','liat.eagle@autodesk.com','uzi.berko@autodesk.com','tal.negrin@autodesk.com']
mailingListCC=['guy.morad@autodesk.com','moshe.almog@autodesk.com','tian.tian@autodesk.com']


#for total
categoryIDsDir = File.dirname(__FILE__)  + '/CategoryIDs/Categories/'
subCategoryIDsDir = File.dirname(__FILE__)  + '/CategoryIDs/SubCategories/'
productIDsDir  = File.dirname(__FILE__)  + '/ProductIDs/'
emptyCatsDir  = File.dirname(__FILE__)  + '/EmptyCategories/'
reportsDir  = File.dirname(__FILE__)  + '/Reports/'
logDir = File.dirname(__FILE__) + "/log.txt"

#for new same and remvoed
discrepanciesCatDir = File.dirname(__FILE__)  + '/Discrepancies/CategoryDiscrepancies/Categories/'
discrepanciesSubCatDir = File.dirname(__FILE__)  + '/Discrepancies/CategoryDiscrepancies/SubCategories/'
discrepanciesProdDir = File.dirname(__FILE__)  + '/Discrepancies/ProductDiscrepancies/'


todayDate = (Date.today).strftime('%Y-%m-%d')
yesterdayDate = (Date.today-1).strftime('%Y-%m-%d')
todayTime = Time.now.strftime('%H:%M')

f = File.open(logDir, "r")
log = f.read
yesterdayTime = log.scan(/#{tenant} executed sendMails #{yesterdayDate} (.*)?/)[0][0]

newCatPath        = discrepanciesCatDir + tenant + "_category_new_" + todayDate + ".txt"
removedCatPath    = discrepanciesCatDir + tenant + "_category_removed_" + todayDate + ".txt"
sameCatPath       = discrepanciesCatDir + tenant + "_category_same_" + todayDate + ".txt"

newSubCatPath     = discrepanciesSubCatDir + tenant + "_subCategory_new_" + todayDate + ".txt"
removedSubCatPath = discrepanciesSubCatDir + tenant + "_subCategory_removed_" + todayDate + ".txt"
sameSubCatPath    = discrepanciesSubCatDir + tenant + "_subCategory_same_" + todayDate + ".txt"

newProdPath       = discrepanciesProdDir + tenant + "_product_new_" + todayDate + ".txt"
removedProdPath   = discrepanciesProdDir + tenant + "_product_removed_" + todayDate + ".txt"
sameProdPath      = discrepanciesProdDir + tenant + "_product_same_" + todayDate + ".txt"

emptyCatsPath     = emptyCatsDir + tenant + "_emptyCategories_" + todayDate + ".txt"
reportCatPath     = reportsDir + tenant + "_categoriesData_" + todayDate + ".xlsx"
reportProdPath    = reportsDir + tenant + "_productData_" + todayDate + ".xlsx"



todayTotalCatIDs        = 0
todayNewCatIDs          = 0
todayRemovedCatIDs      = 0
todaySameCatIDs         = 0

todayTotalSubCatIDs     = 0
todayNewSubCatIDs       = 0
todayRemovedSubCatIDs   = 0
todaySameSubCatIDs      = 0


todayTotalProdIDs       = 0
todayNewProdIDs         = 0
todayRemovedProdIDs     = 0
todaySameProdIDs        = 0

emptyCats               = 0


File.open(newCatPath) {|f| todayNewCatIDs = f.read.count("\n")}
File.open(removedCatPath) {|f| todayRemovedCatIDs = f.read.count("\n")}
File.open(sameCatPath) {|f| todaySameCatIDs = f.read.count("\n")}
todayTotalCatIDs = todayNewCatIDs + todaySameCatIDs

File.open(newSubCatPath) {|f| todayNewSubCatIDs = f.read.count("\n")}
File.open(removedSubCatPath) {|f| todayRemovedSubCatIDs = f.read.count("\n")}
File.open(sameSubCatPath) {|f| todaySameSubCatIDs = f.read.count("\n")}
todayTotalSubCatIDs = todayNewSubCatIDs + todaySameSubCatIDs

File.open(newProdPath) {|f| todayNewProdIDs = f.read.count("\n")}
File.open(removedProdPath) {|f| todayRemovedProdIDs = f.read.count("\n")}
File.open(sameProdPath) {|f| todaySameProdIDs = f.read.count("\n")}
todayTotalProdIDs = todayNewProdIDs + todaySameProdIDs

File.open(emptyCatsPath) {|f| emptyCats = f.read.count("\n")}

color = '#000000'
if(emptyCats > 0) then color = '#B22222' end

#read it from file + give inputs
htmlBody =

'<h2><img src="https://encrypted-tbn3.gstatic.com/images?q=tbn:ANd9GcS6jybShrGEQlY_apWOx_IWQPvrq6tiez-uB0xZ-kjY_96siJsfpg" width="65" height="65" align="middle">&nbsp;&nbsp;' + tenant.capitalize + ' Catalog Status Report</h2>' +

'<p><u>Below is <b>' + tenant.capitalize + '</b> catalog status report, covering <b>' + yesterdayDate + " (" + yesterdayTime + ")" + '</b> - <b>' + todayDate + " (" + todayTime + ")" + '</b>:</u></p>' +

'<p><strong>Environment: </strong>' + env + '.</p>' +

'<p><strong>Number of empty categories: </strong><span style="color:'+color+';">' + emptyCats.to_s + '</span>.</p>' +

'<table  align="center" border="1" cellpadding="1" cellspacing="1" style="width: 500px;">' +
'<thead>' +
'<tr BGCOLOR="#E8E8E8">' +
'<th scope="col"><span class="marker"><kbd></kbd></span></th>' +
'<th scope="col"><span class="marker"><kbd>Parent Categories</kbd></span></th>' +
'<th scope="col"><span class="marker"><kbd>Sub Categories</kbd></span></th>' +
'<th scope="col"><span class="marker"><kbd>Products (non unique instances)</kbd></span></th>' +
'</tr>' +
'</thead>' +
'<tbody>' +
'<tr>' +
'<td BGCOLOR="#E8E8E8"><strong>Total:</strong></td>' +
'<td>' + todayTotalCatIDs.to_s + '</td>' +
'<td>' + todayTotalSubCatIDs.to_s + '</td>' +
'<td>' + todayTotalProdIDs.to_s + '</td>' +
'</tr>' +
'<tr>' +
'<td BGCOLOR="#E8E8E8"><strong>Same:</strong></td>' +
'<td>' + todaySameCatIDs.to_s + '</td>' +
'<td>' + todaySameSubCatIDs.to_s + '</td>' +
'<td>' + todaySameProdIDs.to_s + '</td>' +
'</tr>' +
'<tr>' +
'<td BGCOLOR="#E8E8E8"><strong>New/Updated:</strong></td>' +
'<td>' + todayNewCatIDs.to_s + '</td>' +
'<td>' + todayNewSubCatIDs.to_s  + '</td>' +
'<td>' + todayNewProdIDs.to_s + '</td>' +
'</tr>' +
'<tr>' +
'<td BGCOLOR="#E8E8E8"><strong>Removed:</strong></td>' +
'<td>' + todayRemovedCatIDs.to_s + '</td>' +
'<td>' + todayRemovedSubCatIDs.to_s + '</td>' +
'<td>' + todayRemovedProdIDs.to_s + '</td>' +
'</tr>' +
'</tbody>' +
'</table>' +

'<p>For a more detailed report, see attached spreadsheets.</p>' +

'<p style="color: rgb(0, 0, 0); font-family: Times; font-size: medium; line-height: normal;">&nbsp;</p>' +

'<address style="color: rgb(0, 0, 0); font-family: Times; font-size: medium; line-height: normal;">Regards,</address>' +

'<address style="color: rgb(0, 0, 0); font-family: Times; font-size: medium; line-height: normal;">Homestyler Web&nbsp;Q.A.</address>'


subject = tenant.capitalize + " catalog status update - " + todayDate + 
			" [New: " + (todayNewCatIDs + todayNewSubCatIDs     + todayNewProdIDs).to_s +
			", Removed: " + (todayRemovedCatIDs + todayRemovedSubCatIDs + todayRemovedProdIDs).to_s +
            ", Same: " + (todaySameCatIDs + todaySameSubCatIDs + todaySameProdIDs).to_s +
			", Empty: " + emptyCats.to_s +
			"]"

rcptList = ""
x = 0
while x < mailingList.length
	rcptList << "To: #{mailingList[x]}"
	x += 1
	if x < mailingList.length
		rcptList << "\n"
	end
end

ccList = ""
x = 0
while x < mailingListCC.length
        ccList << "Cc: #{mailingListCC[x]}"
        x += 1
        if x < mailingListCC.length
                ccList << "\n"
        end
end



filename1 = reportCatPath
filename2 = reportProdPath
# Read a file and encode it into base64 format
filecontent = File.read(filename1)
filecontent2 = File.read(filename2)
encodedcontent = [filecontent].pack("m")   # base64
encodedcontent2 = [filecontent2].pack("m")
displayname1=filename1
displayname2=filename2
displayname1[reportsDir]=""
displayname2[reportsDir]=""
marker = "AUNIQUEMARKER"


# Define the main headers.
part1 =<<EOF
From:Homestyler Web QA<homestyler.web.qa@autodesk.com>
#{rcptList}
#{ccList}
Subject: #{subject}
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary=#{marker}
--#{marker}
EOF

# Define the message action
part2 =<<EOF
Content-Type: text/html
Content-Transfer-Encoding:8bit

#{htmlBody}
--#{marker}
EOF

# Define the attachment section
part3 =<<EOF
Content-Type: multipart/mixed; name=\"#{displayname1}\"
Content-Transfer-Encoding:base64
Content-Disposition: attachment; filename="#{displayname1}"

#{encodedcontent}

--#{marker}
EOF

# Define the attachment section
part4 =<<EOF
Content-Type: multipart/mixed; name=\"#{displayname2}\"
Content-Transfer-Encoding:base64
Content-Disposition: attachment; filename="#{displayname2}"

#{encodedcontent2}

--#{marker}--
EOF

mailtext = part1 + part2 + part3 + part4

# Let's put our code in safe area
begin
  Net::SMTP.start('mail.autodesk.com') do |smtp|
     smtp.sendmail(mailtext, 'homestyler.web.qa@autodesk.com',
                          mailingList,mailingListCC)
  end
rescue Exception => e
  print "Exception occured: " + e
end



#gmail = Gmail.new('HS.DataMonitor@gmail.com', 'seeanchange31')


#gmail.deliver do
#    to mailingList
#	cc mailingListCC
#    subject tenant.capitalize + " catalog status update - " + todayDate + 
#			" [+: " + (todayNewCatIDs + todayNewSubCatIDs     + todayNewProdIDs).to_s +
#			", -: " + (todayRemovedCatIDs + todayRemovedSubCatIDs + todayRemovedProdIDs).to_s +
#            ", =: " + (todaySameCatIDs + todaySameSubCatIDs + todaySameProdIDs).to_s +
#			", {}: " + emptyCats.to_s +
#			"] (BETA)"

 #   html_part do
 #       content_type 'text/html; charset=UTF-8'
 #       body htmlBody
  #  end
    
#    add_file reportCatPath
#    add_file reportProdPath
    
#end



#gmail.logout

puts "DONE sending mail"

end
