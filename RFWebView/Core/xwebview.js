/*
 Copyright 2015 XWebView

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
*/

XWVPlugin = function(channelName) {
    var channel = webkit.messageHandlers[channelName];
    if (channelName && !channel)
        throw 'channel has not established';

    Object.defineProperty(this, '$channel', {'configurable': true, 'value': channel});
    Object.defineProperty(this, '$references', {'configurable': true, 'value': []});
    Object.defineProperty(this, '$lastRefID', {'configurable': true, 'value': 1, 'writable': true});
}

XWVPlugin.createNamespace = function(namespace, object) {
    var ret = (window[namespace] = object || {});
    return ret;
}

XWVPlugin.createPlugin = function(channelName, namespace, base) {
    XWVPlugin.call(base, channelName);
    return XWVPlugin.createNamespace(namespace, base);
}

XWVPlugin.createConstructor = function(channelName, namespace, type) {
    var ctor = function() {
        // Instance must can be accessed by native object in global context.
        var ctor = this.constructor;
        while (ctor[ctor.$lastInstID] != undefined)
            ++ctor.$lastInstID;
        Object.defineProperty(this, '$instanceID', {'configurable': true, 'value': ctor.$lastInstID});
        ctor[this.$instanceID] = this;

        // Create and initialize native object asynchronously.
        // So constructor should always return a Promise object.
        Object.defineProperty(this, '$properties', {'configurable': true, 'value': {}});
        return XWVPlugin.invokeNative.apply(this, arguments);
    }

    // Principal instance (which id is 0) is the prototype object.
    var proto = new XWVPlugin(channelName);
    ctor.prototype = proto;
    ctor = ctor.bind(null, '+' + (type || '#p'));
    proto.constructor = ctor;
    //ctor.prototype = proto;  // comment to hide prototype object
    ctor.$lastInstID = 1;
    ctor.dispose = function() {
        Object.keys(this).forEach(function(i){
            if (this[i] instanceof XWVPlugin)
                this[i].dispose();
        }, this);
        proto.dispose();
        delete this.$lastInstID;
    }
    XWVPlugin.createNamespace(namespace, ctor);
    return proto;
}

XWVPlugin.defineProperty = function(obj, prop, value, writable) {
    var desc = {'configurable': false, 'enumerable': true };
    if (writable) {
        // For writable property, any change of its value must be synchronized to native object.
        if (!obj.$properties)
            Object.defineProperty(obj, '$properties', {'configurable': true, 'value': {}});
        obj.$properties[prop] = value;
        desc.get = function() { return this.$properties[prop]; }
        if (obj.constructor.$lastInstID)
            desc.set = function(v) {XWVPlugin.invokeNative.call(this, prop, v);}
        else
            desc.set = XWVPlugin.invokeNative.bind(obj, prop);
    } else {
        desc.value = value;
        desc.writable = false;
    }
    Object.defineProperty(obj, prop, desc);
}

XWVPlugin.invokeNative = function(name) {
    if (typeof(name) != 'string' && !(name instanceof String))
        throw 'Invalid invocation';

    var args = Array.prototype.slice.call(arguments, 1);
    

    
    this.$channel.postMessage({
        '$opcode':  name,
        '$operand': args,
        '$target':  this.$instanceID
    });
}

XWVPlugin.shouldPassByValue = function(obj) {
    // See comment in Source/WebCore/bindings/js/SerializedScriptValue.cpp
    var terminal = [
        ArrayBuffer, Blob, Boolean, DataView, Date,
        File, FileList, Float32Array, Float64Array,
        ImageData, Int16Array, Int32Array, Int8Array,
        MessagePort, Number, RegExp, String, Uint16Array,
        Uint32Array, Uint8Array, Uint8ClampedArray
    ];
    var container = [Array, Map, Object, Set];
    if (obj instanceof Object) {
        if (terminal.some(function(ctor) { return obj.constructor === ctor; }))
            return true;
        if (container.some(function(ctor) { return obj.constructor === ctor; })) {
            var self = arguments.callee;
            return Object.getOwnPropertyNames(obj).every(function(prop) {
                return self(obj[prop]);
            });
        }
        return false;
    }
    return true;
}


XWVPlugin.prototype = {
    $retainObject: function(obj, force) {
        if (!force && XWVPlugin.shouldPassByValue(obj))
            return obj;

        while (this.$references[this.$lastRefID] != undefined)
            ++this.$lastRefID;
        this.$references[this.$lastRefID] = obj;
        return {'$sig': 0x5857574F, '$ref': this.$lastRefID++};
    },
    $releaseObject: function(refid) {
        delete this.$references[refid];
        this.$lastRefID = refid;
    },
    dispose: function(immediate) {
        if (!immediate) {
            this.$channel.postMessage({'$opcode': '-', '$target': this.$instanceID});
            return;
        }

        delete this.$channel;
        delete this.$properties;
        delete this.$references;
        delete this.$lastRefID;
        if (this.$instanceID) {
            // Dispose instance
            this.constructor.$lastInstID = this.$instanceID;
            delete this.constructor[this.$instanceID];
            delete this.$instanceID;
            this.__proto__ = Object.getPrototypeOf(this.__proto__);
        }
        this.__proto__ = Object.getPrototypeOf(this.__proto__);
    }
}

XWVPlugin.context = new XWVPlugin(0);
