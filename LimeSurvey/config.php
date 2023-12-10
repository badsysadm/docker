<?php if (!defined('BASEPATH')) {
    exit('No direct script access allowed');
}

return array(
    'name' => 'LimeSurvey',
    'components' => array(
        'db' => array(
            'connectionString' => 'pgsql:host=LIMESURVEY_DB_HOST;port=LIMESURVEY_DB_PORT;dbname=LIMESURVEY_DB_NAME;',
            'username' => 'LIMESURVEY_DB_USERNAME',
            'password' => 'LIMESURVEY_DB_PASSWORD',
            'charset' => 'utf8',
            'tablePrefix' => 'lime_',
        ),
        'session' => array (
            'class' => 'application.core.web.DbHttpSession',
            'connectionID' => 'db',
            'sessionTableName' => '{{sessions}}',
        ),
    ),
    'config'=>array(
        'debug'=>0,
        'debugsql'=>0,
    )
);
?>
