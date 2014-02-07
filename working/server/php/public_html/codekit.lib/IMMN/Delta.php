<?php
namespace Att\Api\IMMN;

/* vim: set expandtab tabstop=4 shiftwidth=4 softtabstop=4 */

/**
 * IMMN Library
 * 
 * PHP version 5.4+
 * 
 * LICENSE: Licensed by AT&T under the 'Software Development Kit Tools 
 * Agreement.' 2013. 
 * TERMS AND CONDITIONS FOR USE, REPRODUCTION, AND DISTRIBUTIONS:
 * http://developer.att.com/sdk_agreement/
 *
 * Copyright 2013 AT&T Intellectual Property. All rights reserved.
 * For more information contact developer.support@att.com
 * 
 * @category  API
 * @package   IMMN
 * @author    pk9069
 * @copyright 2013 AT&T Intellectual Property
 * @license   http://developer.att.com/sdk_agreement AT&amp;T License
 * @link      http://developer.att.com
 */

require_once __DIR__ . '/DeltaChange.php';

use Att\Api\IMMN\IMMNDeltaChange;

/**
 * Immutable class used to hold a Delta object.
 *
 * @category API
 * @package  IMMN
 * @author   pk9069
 * @license  http://developer.att.com/sdk_agreement AT&amp;T License
 * @version  Release: @package_version@ 
 */
final class Delta
{
    private $_type;
    private $_adds;
    private $_deletes;
    private $_updates;

    public function __construct($type, $adds, $deletes, $updates)
    {
        $this->_type = $type;
        $this->_adds = $adds;
        $this->_deletes = $deletes;
        $this->_updates = $updates;
    }

    public function getDeltaType()
    {
        return $this->_type;
    }

    public function getAdds()
    {
        return $this->_adds;
    }

    public function getDeletes()
    {
        return $this->_deletes;
    }

    public function getUpdates()
    {
        return $this->_updates;
    }

    private static function getDeltaChanges($arr)
    {
        $deltaChanges = array();
        foreach($arr as $deltaChangeArr) {
            $deltaChange = IMMNDeltaChange::fromArray($deltaChangeArr);
            $deltaChanges[] = $deltaChange;
        }

        return $deltaChanges;
    }

    public static function fromArray($arr)
    {
        $type = $arr['type'];
        $adds = Delta::getDeltaChanges($arr['adds']); 
        $deletes = Delta::getDeltaChanges($arr['deletes']); 
        $updates = Delta::getDeltaChanges($arr['updates']); 

        return new Delta($type, $adds, $deletes, $updates);
    }
    
}

?>
