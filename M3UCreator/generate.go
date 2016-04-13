package main
import (
    "fmt"
    "runtime"
    "io/ioutil"
    "strings"
    "os"
)

var root_dir string
var filter_rule map[string]string
var output_prefix string
var output_filename string
var result []string

func initValues(){
	root_dir = "/Volumes/Untitled/"

	filter_rule = map[string]string{}
	filter_rule["file_name_has"] = "梁靜茹"

	output_prefix = "/mnt/external_sd/Music"
	output_filename = "梁靜茹歌單.m3u"

	result = make([]string, 0)

	// playlist will random?
	runtime.GOMAXPROCS(runtime.NumCPU())
}

func check(err error){
	if err != nil{
		fmt.Fprintf(os.Stderr, "has error: %s", err.Error())
        os.Exit(1)
	}
}

func _file_has_name(file_name_has string, path string, f os.FileInfo) bool{
	if strings.Contains(path, file_name_has) {
		return true
	}
	if strings.Contains(f.Name(), file_name_has) {
		return true
	}
	return false
}

func fileFilter(path string, f os.FileInfo) bool {
	name := f.Name()
	if(strings.HasPrefix(name, ".")){
		return false;
	}
	if(strings.HasPrefix(name, "._")){
		return false;
	}
	if(strings.HasSuffix(name, ".jpg")){
		return false;
	}
	if(strings.HasSuffix(name, ".png")){
		return false;
	}

	file_name_has, present := filter_rule["file_name_has"]
	if present {
		if _file_has_name(file_name_has, path, f) {
			return true
		}
	}
	return false
}

func intoSubFolder(dstDir string, pc chan int){
	files, err := ioutil.ReadDir(dstDir)
    check(err)
    file_num := len(files)
    ch := make(chan int, file_num)
    for i, f := range files{
    	path := dstDir + "/" + f.Name()
    	if f.IsDir() {
    		go intoSubFolder(path, ch)
    		continue
    	}
    	if fileFilter(path, f) {
    		path = strings.Replace(path, root_dir, output_prefix, 1)
    		result = append(result, path)
    	}
    	ch <- i
    }
    for i := 0; i < file_num; i++{
    	<- ch
    }
    pc <- 1
}

func outputResult(){
	fo, err := os.Create(output_filename)
    check(err)

    // close fo on exit and check for its returned error
    defer func() {
        if err := fo.Close(); err != nil {
            check(err)
        }
    }()

	for i, v := range result{
		fmt.Printf("%d - %s\n", i, v)
		v = v + "\n"
		if _, err := fo.Write( []byte(v) ); err != nil {
            check(err)
        }
	}
}

func main(){
	initValues()
	ch := make(chan int)
	go intoSubFolder(root_dir, ch)
	<- ch
	outputResult()
}