namespace my.bookshop;
using { Currency, managed, cuid, User } from '@sap/cds/common';

type BusinessObject : String(255);
annotate BusinessObject with @(
  title       : '{i18n>BusinessObject}',
  description : '{i18n>BusinessObject.Description}'
);
/** 
Entity to store change requests for entities JSON serialized.
*/
entity Approval : managed, cuid {
    approver              : User         @( title: 'Approver',);
    changedEntity         : String(255)  @( title: 'Changed Entity', );
    changedEntityKey      : LargeString  @( title: 'Changed Entity Key', );
    changedEntityData     : LargeString  @( title: 'Changed Entity Data', );
    testDecimalFloat      : DecimalFloat @( title: 'Test Decimal Float', );
    testDecimal           : Decimal(9,2) @( title:'Test Decimal (9,2)' );

    status                : String(1) 
      @( title: 'Status', ) enum {
        requested = 'R' @( title: 'Requested');
        pending   = 'P' @( title: 'Pending');
        approved  = 'A' @( title: 'Approved');
        rejected  = 'N' @( title: 'Rejected');
    };
};

entity Books : managed {
  key ID : Integer;
  title  : localized String(111);
  descr  : localized String(1111);
  author : association to Authors { ID };
  stock  : Integer;
  price  : Decimal(9,2);
  currency : Currency;
  virtual semanticURLtoAuthor : String;
  weight      : DecimalFloat @title:'Weight (DecimalFloat)';
  height      : Double @title:'Height (Double)';
  width       : Decimal(9,2) @title:'Width (Decimal(9,2))';
  visible     : Boolean @title:'Visible (Boolean)';
  releaseDate : DateTime @title:'Release Date (DateTime)';
  readingTime : Time @title:'Reading Time (Time)';
};

entity Images {
  key ID : UUID;
  @Core.MediaType: 'image/png'
  content : LargeBinary;
  /*
  @Core.IsMediaType : true
  mediatype : String;
  */
}

@Aggregation.ApplySupported.PropertyRestrictions: true
view BooksAnalytics as select from Books {
  key ID,
  @Analytics.Dimension: true
  author,
  @Analytics.Measure: true
  @Aggregation.default: #SUM
  stock,
  @Analytics.Dimension: true
  currency
};

entity Authors : managed {
  key ID : Integer;
  name   : String(111);
  dateOfBirth  : Date;
  dateOfDeath  : Date;
  placeOfBirth : String;
  placeOfDeath : String;
  alive: Boolean; 
  books  : Association to many Books on books.author = $self;
}

entity Orders : cuid, managed {
  OrderNo         : String @title:'Order Number'; //> readable key
  CustomerOrderNo : String(80) @title:'Customer Order Number';
  Items           : Composition of many OrderItems on Items.parent = $self;
  ShippingAddress : Composition of one OrderShippingAddress on ShippingAddress.parent = $self;
  total           : Decimal(9,2) @readonly;
  currency        : Currency;
}

entity OrderItems : cuid {
  parent  : Association to Orders not null;
  book   : Association to Books;
  amount : Integer;
  netAmount: Decimal(9,2);
}

entity OrderShippingAddress : cuid, managed {
  parent : Association to Orders not null;
  street : String(60) @( title: 'Street', );
  city : String(60) @( title: 'City', );
};

entity Users {
  key username : String @( title: 'Username', );
  address      : Composition of Address on address.parent=$self;
  role         : Association to Roles;
};

entity Address : cuid, managed {
  parent : Association to Users;
  street : String(60) @( title: 'Street', );
  city : String(60) @( title: 'City', );
};

entity BusinessObjects {
  key ID   : BusinessObject;
  parent   : Association to BusinessObjects;
  children : Composition of many BusinessObjects on children.parent = $self;
};

entity Roles : cuid, managed {
      rolename    : String(255) @( title: 'Role Name', );
      description : String      @( title: 'Description', );
      read        : Boolean     @( title: 'Read', );
      authcreate  : Boolean     @( title: 'Create', );
      authupdate  : Boolean     @( title: 'Update', );
      approve     : Boolean     @( title: 'Approve', );
      BusinessObjects : Composition of many Role_BusinessObject on BusinessObjects.parent=$self;
      Users           : Composition of many Role_User on Users.parent=$self;
};

entity Role_BusinessObject : cuid {
  parent : Association to Roles;
  BusinessObject : BusinessObject;
};

entity Role_User : cuid {
  parent : Association to Roles;
  user : User;
};
