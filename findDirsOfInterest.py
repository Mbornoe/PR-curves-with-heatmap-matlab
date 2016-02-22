import os
import csv
def mergeWorkers(filePath):
    print("Merging Workers in: %s" % filePath)

    f = open(os.path.join(filePath, "merged.csv"), "w")
    for dirname, dirnames, filenames in os.walk(filePath):
        for filename in filenames:
            if filename.endswith(".csv"):
                print filename
                reader = csv.reader(open( os.path.join(filePath, filename), "r"))
                for row in reader:
                    #print row[0]
                    #rows.append(row)
                    f.write("%s\n" % row[0])
    f.close()
    #writer = csv.writer(open( os.path.join(filePath, "merged.csv") , "wb" ))
    #writer.writerows("\n".join(rows))

def findDirsOfInterest():
    files = []
    for dirname, dirnames, filenames in os.walk('.'):
        if '.git' in dirnames:
            dirnames.remove('.git')

        for subdirname in dirnames:
            if(subdirname == 'workerOut'):
                if( os.path.isfile( os.path.join(dirname, subdirname)+'/merged.csv') == False ):
                    print("No merged file in: " + os.path.join(dirname, subdirname))
                    mergeWorkers(os.path.join(dirname, subdirname))

        for filename in filenames:
            if(filename=='merged.csv'):
                thisFile = os.path.join(dirname, filename)
                #print(thisFile)
                files.append(thisFile)

    return files

def main():
    detectionPaths = findDirsOfInterest()


if __name__ == "__main__":
    main()
