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

require_once __DIR__ . '/Message.php';

use Att\Api\IMMN\IMMNMessage;

final class IMMNMessageList
{
    private $_msgs;
    private $_limit;
    private $_offset;
    private $_total;
    private $_state;
    private $_cacheStatus;
    private $_failedMessages;

    // disallow default contructor
    private function __construct()
    {
        $_msgs = null;
        $_limit = null;
        $_offset = null;
        $_total = null;
        $_state = null;
        $_cacheStatus = null;
        $_failedMessages = null;
    }

    public function getMessages()
    {
        return $this->_msgs;
    }

    public function getLimit()
    {
        return $this->_limit;
    }

    public function getOffset()
    {
        return $this->_offset;
    }

    public function getTotal()
    {
        return $this->_total;
    }

    public function getState()
    {
        return $this->_state;
    }

    public function getCacheStatus()
    {
        return $this->_cacheStatus;
    }

    public function getFailedMessages()
    {
        return $this->_failedMessages;
    }

    public static function fromArray($arr)
    {
        $immnMsgList = new IMMNMessageList();

        // TODO: finish
        $msgList = $arr['messageList'];

        $immnMsgList->_offset = $msgList['offset'];
        $immnMsgList->_limit = $msgList['limit'];
        $immnMsgList->_total = $msgList['total'];
        $immnMsgList->_state = $msgList['state'];
        $immnMsgList->_cacheStatus = $msgList['cacheStatus'];
        
        if (isset($msgList['failedMessages'])) {
            $immnMsgList->_failedMessages = $msgList['failedMessages'];
        }

        $msgs = $msgList['messages'];
        $immnMsgs = array();

        foreach ($msgs as $msg) {
            $immnMsgs[] = IMMNMessage::fromArray($msg);
        }

        $immnMsgList->_msgs = $immnMsgs;

        return $immnMsgList;
    }

}

?>
