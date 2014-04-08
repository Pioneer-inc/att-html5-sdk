<?php
namespace Att\Api\MMS;

/* vim: set expandtab tabstop=4 shiftwidth=4 softtabstop=4 */

/**
 * MMS Library
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
 * @package   MMS 
 * @author    pk9069
 * @copyright 2013 AT&T Intellectual Property
 * @license   http://developer.att.com/sdk_agreement AT&amp;T License
 * @link      http://developer.att.com
 */
require_once __DIR__ . '/DeliveryInfo.php';

/**
 * Immutable class that holds an MMS status.
 *
 * @category API
 * @package  MMS
 * @author   pk9069
 * @license  http://developer.att.com/sdk_agreement AT&amp;T License
 * @version  Release: @package_version@ 
 * @link     https://developer.att.com/docs/apis/rest/3/MMS
 */
final class Status
{
    private $_resourceUrl;

    private $_deliveryInfoList;

    public function __construct($resourceUrl, $deliveryInfoList)
    {
        $this->_resourceUrl = $resourceUrl;
        $this->_deliveryInfoList = $deliveryInfoList;
    }

    public function getResourceUrl()
    {
        return $this->_resourceUrl;
    }

    public function getDeliveryInfoList()
    {
        return $this->_deliveryInfoList;
    }

    public static function fromArray($arr)
    {
        // TODO: throw exception if required fields are not set
        
        $infoList = $arr['DeliveryInfoList'];
        $resourceUrl = $infoList['ResourceUrl'];

        $dInfoListModel = array();

        $deliveryInfoList = $infoList['DeliveryInfo'];
        foreach($deliveryInfoList as $deliveryInfo) {
            $dInfoModel = DeliveryInfo::fromArray($deliveryInfo);
            $dInfoListModel[] = $dInfoModel;
        }

        return new Status($resourceUrl, $dInfoListModel);
    }

}

?>
