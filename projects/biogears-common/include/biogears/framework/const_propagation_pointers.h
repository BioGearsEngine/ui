#ifndef BIOGEARS_FRAMEWORK_CONST_PROPIGATION_POINTER_H
#define BIOGEARS_FRAMEWORK_CONST_PROPIGATION_POINTER_H

//! Copyright (C) Applied Research Associates - All rights Reserved
//! Unauthorized copying of this file, via any medium is strictly prohibited
//! Proprietary and confidential
//!
//! This file is subject to the terms and conditions defined in file
//! 'LICENSE.txt', which is part of this source code package

//!
//! \file
//! \author Steven A White
//! \date   November 1st 2017
//! \brief  The goal of this class is to allow
//!         unique_ptr and shared_ptr to properly propagate constness
//!         and prevent the use of non const functions from unique_ptr
//!         In general the class should never point to a null object

#include <memory>

namespace biogears {

template <class Implementation>
class Unique_Prop_Ptr {
public:
  template <typename... PARAMS>
  Unique_Prop_Ptr(PARAMS...);
  Unique_Prop_Ptr(const Unique_Prop_Ptr&);
  Unique_Prop_Ptr(Unique_Prop_Ptr&&);

  Implementation* const operator->();
  Implementation const* const operator->() const;

  Unique_Prop_Ptr copy() const;
  Unique_Prop_Ptr deep_copy() const;

  Unique_Prop_Ptr& operator=(nullptr_t);

private:
  std::unique_ptr<Implementation> _impl;
};

template <class Implementation>
template <typename... PARAMS>
Unique_Prop_Ptr<Implementation>::Unique_Prop_Ptr(PARAMS... params)
  : _impl(std::make_unique<Implementation>(Implementation(std::forward<PARAMS>(params)...)))
{
}
template <class Implementation>
Unique_Prop_Ptr<Implementation>::Unique_Prop_Ptr(const Unique_Prop_Ptr& obj)
  : _impl( std::make_unique<Implementation>(*obj._impl))
{
}

template <class Implementation>
Unique_Prop_Ptr<Implementation>::Unique_Prop_Ptr(Unique_Prop_Ptr&& obj)
  : _impl(std::move(obj._impl))
{
}

template <class Implementation>
Implementation* const Unique_Prop_Ptr<Implementation>::operator->()
{
  return _impl.get();
}

template <class Implementation>
Implementation const* const Unique_Prop_Ptr<Implementation>::operator->() const
{
  return _impl.get();
}

template <class Implementation>
Unique_Prop_Ptr<Implementation>& Unique_Prop_Ptr<Implementation>::operator=(nullptr_t)
{
  _impl = nullptr;
  return *this;
}
template <class Implementation>
Unique_Prop_Ptr<Implementation> Unique_Prop_Ptr<Implementation>::copy() const
{
  return Unique_Prop_Ptr<Implementation>(*this->_impl);
}
template <class Implementation>
Unique_Prop_Ptr<Implementation> Unique_Prop_Ptr<Implementation>::deep_copy() const
{
  return Unique_Prop_Ptr<Implementation>(this->_impl->deep_copy());
}
template <class Implementation>
class Shared_Prop_Ptr {
public:
  template <typename... PARAMS>
  Shared_Prop_Ptr(PARAMS...);

  Implementation* const operator->();
  Implementation const* const operator->() const;

private:
  std::shared_ptr<Implementation> _impl;
};

template <class Implementation>
template <typename... PARAMS>
Shared_Prop_Ptr<Implementation>::Shared_Prop_Ptr(PARAMS... params)
  : _impl(std::make_shared<Implementation>(Implementation(std::forward<PARAMS>(params)...)))
{
}
template <class Implementation>
Implementation* const Shared_Prop_Ptr<Implementation>::operator->()
{
  return _impl.operator->();
}

template <class Implementation>
Implementation const* const Shared_Prop_Ptr<Implementation>::operator->() const
{
  return _impl.operator->();
}
}

#endif //BIOGEARS_FRAMEWORK_CONST_PROPIGATION_POINTER_H
