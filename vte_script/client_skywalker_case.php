<?php

//PrintDebug($argv);
$params = array('app'=>'xiaotian', 
                'mod'=>'skywalker',
                'action'=>'script',
                'platform'=>$_SERVER["argv"][1],
                'priority'=>'1,2,3'
                );
//print_r($params);        

try{
    $soapclient = new SoapClient(null,array(
        'location'=>"http://umbrella/XiaoTian/NewCode/services/server.php",
        'uri'=>'server.php',
        'trace'=>1,
        'exception'=>0));
//print_r($soapclient);        
    $result = $soapclient->startResponse($params);
    print_r($result); // return the cycle id
    if (empty($result)){ // fail
        print_r("Fail to create the cycle.");
    }
    else{
        print_r("Success to create the cycle, cycle_id=$result");
    }
}catch(SoapFault $e){
//print_r($e);
    echo $e->getMessage();
}catch(Exception $e){
//print_r($e);
    echo $e->getMessage();
}

?>
