require 'date'
require_relative 'getCatData'
require_relative 'getProductData'
require_relative 'getDiscrepancies'
require_relative 'getEmptyCats'
require_relative 'generateReport'
require_relative 'sendMails'

require_relative 'getProductData'

env      = ARGV[0]
tenant   = ARGV[1]
status   = ARGV[2]

if(status == nil) then status = "1" end

folder = File.dirname(__FILE__)
logDir = File.dirname(__FILE__) + "/log.txt"

todayDate     = (Date.today).strftime('%Y-%m-%d')
todayTime     = Time.now.strftime('%H:%M')
yesterdayDate = (Date.today-1).strftime('%Y-%m-%d')

#getProductPath("beta", "homestyler", "74ac47a3-1dd3-4ae6-a7d5-eb80c6a6f2f7")

# add retries here

def deleteFile(file_path)
    puts "Delete file: " + file_path.to_s
    File.delete(file_path) if File.exist?(file_path)
end


def cleanUp(folder, tenant, yesterdayDate)
    Dir.glob("#{folder}/**/*#{tenant}*").each {|i|
        if ((!i.include? yesterdayDate) ) then
            deleteFile(i)
        end
    }
end

cleanUp(folder, tenant, yesterdayDate)

getCatData(env, tenant, status)
open(logDir, 'a') do |f| f << tenant + " executed getCatData " + todayDate + " " + todayTime + "\n"  end

getProductData(env, tenant, status)
open(logDir, 'a') do |f| f << tenant + " executed getProductData " + todayDate + " " + todayTime + "\n"  end

getEmptyCats(env, tenant)
open(logDir, 'a') do |f| f << tenant + " executed getEmptyCats " + todayDate + " " + todayTime + "\n"  end

getDiscrepancies(tenant)
open(logDir, 'a') do |f| f << tenant + " executed getDiscrepancies " + todayDate + " " + todayTime + "\n"  end

generateReport(tenant)
open(logDir, 'a') do |f| f << tenant + " executed generateReport " + todayDate + " " + todayTime + "\n"  end

sendMails(env, tenant)
open(logDir, 'a') do |f| f << tenant + " executed sendMails " + todayDate + " " + todayTime + "\n"  end


puts 'Data Monitor executed'


