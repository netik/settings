# jna's .bash profile

echo -n "(.profile"

# ---------------- Environment ----------------
# for EC2
export EDITOR=emacs

export EC2_CERT=~/.ec2/cert-W45LMZKFDOXECYVVUPW76VCI7ZARAM3S.pem
export EC2_HOME=/Users/jna/src/ec2-api-tools-1.3-53907
export EC2_PRIVATE_KEY=~/.ec2/pk-W45LMZKFDOXECYVVUPW76VCI7ZARAM3S.pem
export EDITOR=emacs   # edit to taste
export EDITOR=vi

export HISTFILESIZE=10000 # Record last 10,000 commands
export HISTSIZE=10000 # Record last 10,000 commands per session

#PATH=/opt/local/bin:/opt/local/sbin:/usr/local/bin:/Users/jna/.gem/ruby/1.8/bin:~/bin:/Users/jna/seco/tools/bin:/Users/jna/src/ec2-api-tools-1.3-53907/bin:/bin:/sbin:/twitter/httpd/bin:/usr/X11/bin:/usr/bin:/usr/local/bin:/usr/local/mysql/bin:/usr/sbin:/Applications/sshfs/bin:/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/bin:/usr/local/scala/bin:/opt/local/Library/Frameworks/Python.framework/Versions/2.6/bin:~/security/msf3
#export PATH

# my previous path was obscene, let's try this. 
#export PATH=/bin:/usr/bin:/usr/sbin:/sbin:/opt/local/bin:/opt/local/sbin:/usr/local/bin:/usr/X11/bin:/usr/local/mysql/bin

export PATH=$HOME/bin:/Library/PostgreSQL/9.2/bin:/opt/local/bin:/bin:/usr/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/X11/bin:/usr/local/mysql/bin:/Users/jna/src/ec2-api-tools-1.3-53907/bin:/Users/jna/bin/apache-maven-3.0.x/bin:~/bin/adt-bundle-mac-x86_64-20130522/sdk/tools/:~/bin/adt-bundle-mac-x86_64-20130522/sdk/platform-tools


# for android dev
#PATH=$PATH:/Android/android-sdk-macosx:/Android/android-sdk-macosx/tools:/Android/android-sdk-macos:/Android/android-sdk-macosx/platform-tools
#export PATH

export RAILS_ENV='development'
export RATPROXY="/Users/jna/security/proxies/ratproxy/ratproxy"
export RUBY_GC_MALLOC_LIMIT=50000000
export RUBY_HEAP_MIN_SLOTS=250000
export RUBY_HEAP_SLOTS_GROWTH_FACTOR=1
export RUBY_HEAP_SLOTS_INCREMENT=250000
export PYTHONPATH=$PYTHONPATH:/Library/Python/2.5/site-packages/:~/lib/python


export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/mysql/lib:/usr/local/lib:/opt/local/lib
export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:/usr/local/mysql/lib

# ---------------- Functions ------------------

# mostused 
function mostused() {
    cat ~/.bash_history | cut -d" " -f1 | frequency | sort -rn | head
}

# cmyru
function cymru() { 
    whois -h whois.cymru.com " -v $1 "
}

# pretty print using enscript
function plp {
    enscript -2 -r -G --color=true $1
}

# openssl s_client stuff
function scl {
  echo "" | openssl s_client -host $1 -port 443 -showcerts 
}

# MacOS Seq Emulation
function seq() { 
  cnt=$1
  while [ $cnt -ne $(( $2 +1 )) ]; do 
    echo $cnt
    cnt=$(( $cnt + 1 ))
  done
}

function find_java() {
    if [ ! -z "$JAVA_HOME" ]; then
        return
    fi

    potential=$(ls -r1d /opt/jdk /System/Library/Frameworks/JavaVM.framework/Versions/CurrentJDK/Home /usr/java/j* /usr/java/default 2>/dev/null)
    for p in $potential; do
        if [ -x $p/bin/java ]; then
            JAVA_HOME=$p
            break
        fi
    done

    export JAVA_HOME
}

find_java

function git-refresh() {
  (
    cd ~/twitter/twitter

    current_branch=`git branch | grep '*' | sed 's/* //g'`
    if [[ "xx" != "x${current_branch}x" ]];then
      git checkout master
      git pull
      git checkout ${current_branch}
      git merge master
    fi
  )
}

function wget() { /opt/local/bin/curl -O $*; } 
function la() { /bin/ls -Fa $*; }
function ls() { /bin/ls -F $*; }
function lsl() { l -l $*; }
function lsla() { la -lg $*; }
function l.() { /bin/ls .[A-Za-z]* $*; }
function j() { jobs -l; }
function dg() { ssh -l decay khurla.pair.com; }
function rehash() { builtin hash -r; }
function rlogin() { /usr/ucb/rlogin $*; }
function deploysh() { echo "cd twitter; cap production shell"; ssh -tt -l jna nest1.twitter.com sudo su - twitter; } 

function showcert() { openssl x509 -in $1 -text; }

function lscert() { 
  # list a directory and list out the subjects. 
  for i in *; 
  do
     SUB=`showcert $i | grep Subject | sed 's/Subject: //'`
     echo $i: ${SUB}
  done
}

function showkey() { openssl rsa -in $1 -text; }

function keycompare() { 
  # compare a private key to a public key and tell me if they are valid. 
  um=`umask` # stash away our current umask
  umask 077
  id=$$

  fn=$1
  pk=${fn%.*}.key
  pub=${fn%.*}.cert

  showkey $pk > /tmp/key.$$ 
  showcert $pub > /tmp/pub.$$

  # extract the modulus
  sed -n '/^publicExponent:/q;p' /tmp/key.$id  | grep -v modulus | grep -v Priv | sed s/\ //g > /tmp/key.mod.$id
  sed -n '/Exponent:/q;p' /tmp/pub.$id  | egrep '                    ' | sed s/\ //g > /tmp/pub.mod.$id

  diff /tmp/key.mod.$id /tmp/pub.mod.$id  #> /dev/null

  if [ $? != 0 ]; then
    echo "$fn: Modulus does not match."
    echo "---key..."
    cat /tmp/key.mod.$id
    echo "---pub..."
    cat /tmp/pub.mod.$id
  else 
    echo "$fn: Modulus matches! OK."
  fi

  # cleanup
  rm /tmp/key.$id
  rm /tmp/pub.$id
  rm /tmp/key.mod.$id
  rm /tmp/pub.mod.$id

  umask $um
}

# ---- aliases ----
alias ack='ack --type-add pp=.pp --type=pp --type-add erb=.erb'
alias start_mysql='sudo /usr/local/mysql/bin/mysqld_safe &'
alias stop_mysql='mysqladmin shutdown -uroot -p'
alias scpresume="rsync --partial --progress --rsh=ssh"
alias ratproxy="$RATPROXY -v ~/security/scans -w ~/security/scans/twitter.out -d twitter.com -lfjxscm "
alias ratproxyXSS="$RATPROXY -v ~/security/scans -w ~/security/scans/twitter.out -d twitter.com -lejxfscm -XC"
alias ratproxyv="$RATPROXY -v ~/security/scans -w ~/security/scans/twitter.out -d twitter.com -lexjtifscgjm"
alias ratproxyvXSS="$RATPROXY -v ~/security/scans -w ~/security/scans/twitter.out -d twitter.com -lextjifscgjm -XC"
alias ratreport="( cd /Users/jna/security/proxies/ratproxy; ./ratproxy-report.sh ~/security/scans/twitter.out > ./twitter-report.html; open ./twitter-report.html )"
alias HEAD="curl -I $*"

# host shortcuts
alias sshsmf='ssh nest1.smf1.twitter.com $*'
alias nest1='ssh -D8080 nest1.corp.twitter.com $*'
alias nest2='ssh -D8081 nest2.corp.twitter.com $*'
alias webbox='ssh smf1-ada-27-sr4.prod.twitter.com $*'
alias dirtybird='ssh smf1-adx-35-sr1.prod.twitter.com $*'
alias toolsbox='ssh smf1-adx-35-sr1.prod.twitter.com $*'

# dir shortcuts
alias manifests="cd ~/twitter/twitter-ops/puppet/master/manifests/nodes"
alias modules="cd ~/twitter/twitter-ops/puppet/modules"

# intercept stdio/stdout
alias intercept="strace -ff -e trace=write -e write=1,2 -p $*"

# 
#alias 'sshec2'='ssh -i ~/.ec2/id_rsa-gsg-keypair root@smokeping.twitter.com'
alias 'sshec2'='ssh -i ~/.ec2/id_rsa-gsg-keypair root@184.72.175.124'

function _macosx() 
{ 
    if [ $(uname -s) = Darwin ]; then 
        return 0 
    else 
        return 1 
    fi 
} 

# ----- java ----- 
JDKS_ROOT= 
if [ $(uname -s) = Darwin ]; then 
    JDKS_ROOT=/System/Library/Frameworks/JavaVM.framework/Versions 
fi 
JAVA_1_7_0_HOME=/usr/local/java-1.7.0 

source ~/bin/zer0prompt.sh
zer0prompt
unset zer0prompt


# for code signing
export CODESIGN_ALLOCATE=/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/codesign_allocate
export RAILS_ENV='development'

# Set path to utils checkout from 'git clone
# http://git.local.twitter.com/twitter-utilities'.  See 'Internal CLI
# Tools' section of
# http://trac.local.twitter.com/twttr/wiki/DevEnvironment

UTILS_PATH="$HOME/workspace/twitter-utilities"
if [ -f $UTILS_PATH/twitter.sh ]; then
   . $UTILS_PATH/twitter.sh
fi

# you'll get only as far as the Kestrel part without the below
export SBT_TWITTER=1

# Config for Ruby Version Manager.
if [[ -s $HOME/.rvm/scripts/rvm ]] ; then source $HOME/.rvm/scripts/rvm ; fi

function rf() {
  environments=${*:-"test selenium development"}
  echo "Restarting memcache"
  killall memcached
  memcached -d
  rake kestrel:stop
  rake kestrel:start
  foreach_env " Dropping Database" "$environments" "dropdb"
  foreach_env " Creating Database" "$environments" "createdb"
  foreach_env "Migrating Database" "$environments" "migratedb"
  foreach_env "  Loading Fixtures" "development" "loadfixtures"
}

function foreach_env() {
  msg=$1
  environments=$2
  command=$3
  echo -n "$msg: "
  for env in $environments; do
    echo -n "$env "
    $command $env
  done
  echo
}

function dropdb() {
  env=$1
  mysql --user=root -e "DROP DATABASE twttr_$env;" >/dev/null
}

function createdb() {
  env=$1
  mysql --user=root -e "CREATE DATABASE twttr_$env;" >/dev/null
}

function migratedb() {
  env=$1
  RAILS_ENV=$env rake db:migrate >/dev/null
}

function loadfixtures() {
  env=$1
  RAILS_ENV=$env rake db:fixtures:load >/dev/null
}

function usejdk17 {
  JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.7.0_25.jdk/Contents/Home
  export JAVA_HOME
  
  PATH=${JAVA_HOME}/bin:$PATH
  export PATH

  echo "Using JDK at ${JAVA_HOME}..."

}


# for google
alias whatsmyip='curl http://www.whatismyip.com/automation/n09230945.asp;echo '

function kq() {
  queue=$1
  servers="kestrel001 kestrel002 daemon045 daemon046"
  while true; do
    echo -n "$(date) -- $queue: "
    (
      for kestrel in $servers; do
        (echo "STATS"; sleep 1) | nc $kestrel 22133 | grep queue_${queue}_items | awk '{print $3}' | sed -e 's/\r//'
      done
      echo "0"

      for kestrel in $servers; do
        echo "+"
      done
      echo "p"
    ) | dc
  done
}
# --- end ---
echo ")"


function curl() { 
  /opt/local/bin/curl -H 'User-Agent: Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_6; en-US) AppleWebKit/534.13 (KHTML, like Gecko) Chrome/9.0.597.84 Safari/534.13' $*
}

function curlsf() { 
  /opt/local/bin/curl -L -H 'User-Agent: Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_6; en-US) AppleWebKit/534.13 (KHTML, like Gecko) Chrome/9.0.597.84 Safari/534.13' -O $*
}

function geoip() {
    curl -s  http://www.geody.com/geoip.php?ip=$1 | grep Location:  
}
function showchain() { 
    openssl x509 -in $1 -text | egrep 'Issuer:|Subject:'
}


function pskill() { 
    kill -9 `ps -ef | grep $1 | awk '{ print $2 }'`
}

function mnthubba() { 
 sshfs jna@retina.net:/retina/hubba /Users/jna/hubba
 cd /Users/jna/hubba/showmanager
 mate .
}

function showuser() { 
  ldapsearch -h ldapmaster.twitter.biz -x -b 'cn=users,dc=ods,dc=twitter,dc=corp' "(uid=$1)"
}

function showallusers() { 
  ldapsearch -h ldapmaster.twitter.biz -x -b 'cn=users,dc=ods,dc=twitter,dc=corp' 
}

function showsn() { 
  ldapsearch -h ldapmaster.twitter.biz -x -b 'cn=users,dc=ods,dc=twitter,dc=corp' "(sn=\*$1\*)"
}

function showuid() { 
  ldapsearch -h ldapmaster.twitter.biz -x -b 'cn=users,dc=ods,dc=twitter,dc=corp' "(uidNumber=$1)"
}

function showgroup() { 
  ldapsearch -h ldapmaster.twitter.biz -x -b 'cn=groups,dc=ods,dc=twitter,dc=corp' "(cn=$1)"
}


function showallgroups() { 
  ldapsearch -h ldapmaster.twitter.biz -x -b 'cn=groups,dc=ods,dc=twitter,dc=corp' 
}


function ldaps() { 
  ldapsearch -h ldapmaster.twitter.biz -x -b 'cn=groups,dc=ods,dc=twitter,dc=corp' $*
}


function smfv { 
  ssh -A -p 22474 tfa-smfv.twitter.biz
}

function twssh() {
 keys=$($LDAPSEARCH uid="$1" twSSHPubkey | grep -v "dn:" | tr -d '\n')
 echo "$keys" | grep -i "twsshpubkey::" > /dev/null;  base64=$?
 if [ $base64 -eq 0 ]; then
   echo $keys | cut -d':' -f3 | tr -d ' ' | tr -d '\n' | base64 $B64_OPTIONS && echo ""
 else
   echo $keys | cut -d':' -f2 | tr -d ' '
 fi
}


# for now, always use jdk17
usejdk17

alias keywhiz.cli='java -jar /Users/jna/twitter/keywhiz/cli/target/keywhiz-cli-0.6.4-SNAPSHOT-shaded.jar -d jdbc:postgresql://localhost/keywhiz_development -u keywhiz_development $*'
